defmodule ForestSurveyWeb.ClientsLive do
  use ForestSurveyWeb, :live_view

  alias ForestSurvey.Surveys
  alias ForestSurvey.Surveys.Client

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:form, nil) |> load_clients()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :form, nil)
  end

  defp apply_action(socket, :new, _params) do
    form = AshPhoenix.Form.for_create(Client, :create) |> to_form()
    assign(socket, :form, form)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    client = Surveys.get_client!(id)
    form = AshPhoenix.Form.for_update(client, :update) |> to_form()
    assign(socket, :form, form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _client} ->
        {:noreply,
         socket
         |> put_flash(:info, "Cliente guardado correctamente.")
         |> push_navigate(to: ~p"/admin/clients")
         |> load_clients()}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("archive", %{"id" => id}, socket) do
    with {:ok, client} <- Surveys.get_client(id),
         {:ok, _} <- Surveys.archive_client(client) do
      {:noreply, socket |> put_flash(:info, "Cliente archivado.") |> load_clients()}
    else
      _ -> {:noreply, put_flash(socket, :error, "No se pudo archivar el cliente.")}
    end
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/clients")}
  end

  defp load_clients(socket) do
    assign(socket, :clients, Surveys.list_active_clients!())
  end
end
