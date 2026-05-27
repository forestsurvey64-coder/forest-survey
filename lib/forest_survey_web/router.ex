defmodule ForestSurveyWeb.Router do
  use ForestSurveyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ForestSurveyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ForestSurveyWeb do
    pipe_through :browser

    live_session :default, layout: {ForestSurveyWeb.Layouts, :app} do
      live "/", GeneratorLive, :index
      live "/history", HistoryLive, :index

      live "/admin/vendors", VendorsLive, :index
      live "/admin/vendors/new", VendorsLive, :new
      live "/admin/vendors/:id/edit", VendorsLive, :edit

      live "/admin/clients", ClientsLive, :index
      live "/admin/clients/new", ClientsLive, :new
      live "/admin/clients/:id/edit", ClientsLive, :edit

      live "/admin/config", ConfigLive, :index
      live "/admin/config/new", ConfigLive, :new
      live "/admin/config/:id/edit", ConfigLive, :edit
    end
  end

  scope "/rpc", ForestSurveyWeb do
    pipe_through :api

    post "/run", AshTypescriptRpcController, :run
    post "/validate", AshTypescriptRpcController, :validate
  end

  if Application.compile_env(:forest_survey, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ForestSurveyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Application.compile_env(:forest_survey, :dev_routes) do
    import AshAdmin.Router

    scope "/ash-admin" do
      pipe_through :browser

      ash_admin "/"
    end
  end
end
