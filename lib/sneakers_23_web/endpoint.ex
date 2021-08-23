defmodule Sneakers23Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :sneakers_23

  @session_options [
    store: :cookie,
    key: "_sneakers_23_key",
    signing_salt: "aPsMIUgu"
  ]

  socket "/socket", Sneakers23Web.UserSocket,
    websocket: true,
    longpoll: false

  socket "product_socket", Sneakers23Web.ProductSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  if Application.get_env(:sneakers_23, :sql_sandbox) do
    plug Phoenix.Ecto.SQL.Sandbox
  end

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :sneakers_23,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :sneakers_23
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug Sneakers23Web.Router
end
