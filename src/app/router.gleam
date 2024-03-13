import wisp.{type Request, type Response}
import gleam/string_builder
import gleam/int
import gleam/io
import gleam/result
import gleam/list
import app/web.{type Context}

const layout_string = "<!doctype html>
<html lang='en'>
  <head>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0' />
    <title>Document</title>
    <link href='/static/main.css' rel='stylesheet'/>
    <script src='https://unpkg.com/htmx.org@1.9.10'></script>
  </head>
  <body>
    <app/>
  </body>
</html>
"

const html_target = "<app/>"

fn add_head(
  sb: string_builder.StringBuilder,
  body: String,
) -> string_builder.StringBuilder {
  sb
  |> string_builder.replace(html_target, body)
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> home_page(req)
    ["increment"] -> increment(req)
    ["decrement"] -> decrement(req)
    _ -> wisp.not_found()
  }
}

const input_field = "
<input id='counter' name='counter' type='number' value='$value' readonly='readonly' class='bg-black w-20 text-center'/>
"

fn home_page(_req: Request) -> Response {
  let body = "
  <div class='w-screen h-screen bg-black text-white grid grid-rows-3 place-items-center'> 

    <h1 class='text-4xl font-bold text-[#fffbe8]'>
        <span class='text-[#ffaff3]'>Gleamed</span> all over
    </h1>

    <form class='flex flex-row gap-5 text-5xl'>
        <button hx-post='/increment' hx-target='#counter' hx-swap='outerHTML'>+</button>
        " <> input_field
    |> string_builder.from_string()
    |> string_builder.replace("$value", "0")
    |> string_builder.to_string() <> "
        <button hx-post='/decrement' hx-target='#counter' hx-swap='outerHTML'>-</button>
    </form>
  </div> 
  "

  layout_string
  |> string_builder.from_string()
  |> add_head(body)
  |> wisp.html_response(200)
}

fn increment(req: Request) -> Response {
  use form_data <- wisp.require_form(req)
  let counter = {
    use c <- result.try(list.key_find(form_data.values, "counter"))
    int.parse(c)
  }

  case counter {
    Ok(x) ->
      input_field
      |> string_builder.from_string()
      |> string_builder.replace("$value", int.to_string(x + 1))
      |> wisp.html_response(200)
    Error(_) -> wisp.unprocessable_entity()
  }
}

fn decrement(req: Request) -> Response {
  use form_data <- wisp.require_form(req)
  let counter = {
    use c <- result.try(list.key_find(form_data.values, "counter"))
    int.parse(c)
  }

  case counter {
    Ok(x) ->
      input_field
      |> string_builder.from_string()
      |> string_builder.replace("$value", int.to_string(x - 1))
      |> wisp.html_response(200)
    Error(_) -> wisp.unprocessable_entity()
  }
}
