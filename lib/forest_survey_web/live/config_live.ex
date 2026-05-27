defmodule ForestSurveyWeb.ConfigLive do
  use ForestSurveyWeb, :live_view

  alias ForestSurvey.Surveys
  alias ForestSurvey.Surveys.Config

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:form, nil) |> load_configs()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :form, nil)
  end

  defp apply_action(socket, :new, _params) do
    form = AshPhoenix.Form.for_create(Config, :create) |> to_form()
    assign(socket, :form, form)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    config = Surveys.get_config!(id)
    form = AshPhoenix.Form.for_update(config, :save) |> to_form()
    assign(socket, :form, form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _config} ->
        {:noreply,
         socket
         |> put_flash(:info, "Formulario guardado correctamente.")
         |> push_navigate(to: ~p"/admin/config")
         |> load_configs()}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, config} <- Surveys.get_config(id),
         :ok <- Surveys.destroy_config(config) do
      {:noreply, socket |> put_flash(:info, "Formulario eliminado.") |> load_configs()}
    else
      _ -> {:noreply, put_flash(socket, :error, "No se pudo eliminar.")}
    end
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/config")}
  end

  defp load_configs(socket) do
    assign(socket, :configs, Surveys.list_configs!())
  end
end
