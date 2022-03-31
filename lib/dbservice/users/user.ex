defmodule Dbservice.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field :address, :string
    field :city, :string
    field :district, :string
    field :email, :string
    field :first_name, :string
    field :gender, :string
    field :last_name, :string
    field :phone, :string
    field :pincode, :string
    field :role, :string
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :phone, :gender, :address, :city, :district, :state, :pincode, :role])
    |> validate_required([:first_name, :last_name, :email, :phone])
  end
end
