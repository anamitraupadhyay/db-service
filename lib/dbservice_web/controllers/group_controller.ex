defmodule DbserviceWeb.GroupController do
  use DbserviceWeb, :controller

  import Ecto.Query
  alias Dbservice.Repo
  alias Dbservice.Groups
  alias Dbservice.Groups.Group

  action_fallback DbserviceWeb.FallbackController

  use PhoenixSwagger

  alias DbserviceWeb.SwaggerSchema.Group, as: SwaggerSchemaGroup

  def swagger_definitions do
    # merge the required definitions in a pair at a time using the Map.merge/2 function
    Map.merge(SwaggerSchemaGroup.group(), SwaggerSchemaGroup.groups())
  end

  swagger_path :index do
    get("/api/group")

    parameters do
      params(:query, :string, "The name the group", required: false, name: "name")

      params(:query, :string, "The locale the group",
        required: false,
        name: "locale"
      )
    end

    response(200, "OK", Schema.ref(:Groups))
  end

  def index(conn, params) do
    query =
      from m in Group,
        order_by: [asc: m.id],
        offset: ^params["offset"],
        limit: ^params["limit"]

    query =
      Enum.reduce(params, query, fn {key, value}, acc ->
        case String.to_existing_atom(key) do
          :offset -> acc
          :limit -> acc
          atom -> from u in acc, where: field(u, ^atom) == ^value
        end
      end)

    group = Repo.all(query)
    render(conn, "index.json", group: group)
  end

  swagger_path :create do
    post("/api/group")

    parameters do
      body(:body, Schema.ref(:Group), "Group to create", required: true)
    end

    response(201, "Created", Schema.ref(:Group))
  end

  def create(conn, params) do
    case Groups.get_group_by_name(params["name"]) do
      nil ->
        create_new_group(conn, params)

      existing_group ->
        update_existing_group(conn, existing_group, params)
    end
  end

  swagger_path :show do
    get("/api/group/{groupId}")

    parameters do
      groupId(:path, :integer, "The id of the group record", required: true)
    end

    response(200, "OK", Schema.ref(:Group))
  end

  def show(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    render(conn, "show.json", group: group)
  end

  swagger_path :update do
    patch("/api/group/{groupId}")

    parameters do
      groupId(:path, :integer, "The id of the group record", required: true)
      body(:body, Schema.ref(:Group), "Group to create", required: true)
    end

    response(200, "Updated", Schema.ref(:Group))
  end

  def update(conn, params) do
    group = Groups.get_group!(params["id"])

    with {:ok, %Group{} = group} <- Groups.update_group(group, params) do
      render(conn, "show.json", group: group)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/group/{groupId}")

    parameters do
      groupId(:path, :integer, "The id of the group record", required: true)
    end

    response(204, "No Content")
  end

  def delete(conn, %{"id" => id}) do
    group = Groups.get_group!(id)

    with {:ok, %Group{}} <- Groups.delete_group(group) do
      send_resp(conn, :no_content, "")
    end
  end

  defp create_new_group(conn, params) do
    with {:ok, %Group{} = group} <- Groups.create_group(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.group_path(conn, :show, group))
      |> render("show.json", group: group)
    end
  end

  defp update_existing_group(conn, existing_group, params) do
    with {:ok, %Group{} = group} <- Groups.update_group(existing_group, params) do
      conn
      |> put_status(:ok)
      |> render("show.json", group: group)
    end
  end
end
