defmodule ForestSurveyWeb.HistoryLive do
  use ForestSurveyWeb, :live_view

  alias ForestSurvey.Surveys

  @page_size 50

  @impl true
  def mount(_params, _session, socket) do
    vendors = Surveys.list_active_vendors!()
    clients = Surveys.list_active_clients!()

    {:ok,
     socket
     |> assign(:vendors, vendors)
     |> assign(:clients, clients)
     |> assign(:filter_vendor_id, nil)
     |> assign(:filter_client_id, nil)
     |> assign(:filter_status, nil)
     |> assign(:page, 1)
     |> assign(:total, 0)
     |> load_links()}
  end

  @impl true
  def handle_event("filter", params, socket) do
    socket =
      socket
      |> then(fn s ->
        case params do
          %{"vendor_id" => v} -> assign(s, :filter_vendor_id, nilify(v))
          %{"client_id" => c} -> assign(s, :filter_client_id, nilify(c))
          %{"status" => st} -> assign(s, :filter_status, nilify(st))
          _ -> s
        end
      end)
      |> assign(:page, 1)
      |> load_links()

    {:noreply, socket}
  end

  def handle_event("page", %{"n" => n}, socket) do
    {:noreply, socket |> assign(:page, String.to_integer(n)) |> load_links()}
  end

  def handle_event("mark_as_sent", %{"id" => id}, socket) do
    with {:ok, link} <- Surveys.get_link(id),
         {:ok, _updated} <- Surveys.mark_as_sent(link) do
      {:noreply, socket |> put_flash(:info, "Marcado como enviado.") |> load_links()}
    else
      _ -> {:noreply, put_flash(socket, :error, "No se pudo marcar como enviado.")}
    end
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp load_links(socket) do
    %{
      filter_vendor_id: vendor_id,
      filter_client_id: client_id,
      filter_status: status,
      page: page
    } = socket.assigns

    filter = build_filter(vendor_id, client_id, status)

    links =
      Surveys.list_links!(
        query: [
          filter: filter,
          sort: [inserted_at: :desc],
          limit: @page_size,
          offset: (page - 1) * @page_size
        ],
        load: [:vendor, :client]
      )

    assign(socket, :links, links)
  end

  defp build_filter(vendor_id, client_id, status) do
    []
    |> then(fn f -> if vendor_id, do: [{:vendor_id, vendor_id} | f], else: f end)
    |> then(fn f -> if client_id, do: [{:client_id, client_id} | f], else: f end)
    |> then(fn f ->
      if status && status != "" do
        [{:status, String.to_existing_atom(status)} | f]
      else
        f
      end
    end)
  end

  defp nilify(""), do: nil
  defp nilify(v), do: v

  defp status_badge_class(:pending), do: "badge badge-warning badge-sm"
  defp status_badge_class(:sent), do: "badge badge-success badge-sm"
  defp status_badge_class(:responded), do: "badge badge-info badge-sm"
  defp status_badge_class(:dismissed), do: "badge badge-ghost badge-sm"
  defp status_badge_class(_), do: "badge badge-ghost badge-sm"

  defp status_label(:pending), do: "Pendiente"
  defp status_label(:sent), do: "Enviado"
  defp status_label(:responded), do: "Respondido"
  defp status_label(:dismissed), do: "No procede"
  defp status_label(_), do: "—"
end
