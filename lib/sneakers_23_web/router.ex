defmodule Sneakers23Web.Router do
  use Sneakers23Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Sneakers23Web.CartIdPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Sneakers23Web do
    pipe_through :browser

    get "/", ProductController, :index
    get "/checkout", CheckoutController, :show
    post "/checkout", CheckoutController, :purchase
    get "/checkout/complete", CheckoutController, :success
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: Sneakers23Web.Telemetry
    end
  end
end
