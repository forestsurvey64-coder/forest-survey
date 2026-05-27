defmodule ForestSurveyWeb.PageController do
  use ForestSurveyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
