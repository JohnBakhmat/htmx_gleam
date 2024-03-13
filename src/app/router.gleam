import wisp.{type Request, type Response}
import gleam/string_builder
import app/web.{type Context}

const layout_string = "<!doctype html>
<html lang='en'>
  <head>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0' />
    <title>Document</title>
    <link href='/static/main.css' rel='stylesheet'/>
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
    _ -> wisp.not_found()
  }
}

fn home_page(_req: Request) -> Response {
  let body =
    "
  <div class='w-screen h-screen bg-black text-white grid grid-rows-1 place-items-center'> 
    <h1 class='text-4xl font-bold text-[#fffbe8]'>
        <span class='text-[#ffaff3]'>Gleamed</span> all over
    </h1>
  <div /> 
  "

  layout_string
  |> string_builder.from_string()
  |> add_head(body)
  |> wisp.html_response(200)
}
