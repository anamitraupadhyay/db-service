defmodule Dbservice.Repo.Migrations.UpdateUserSession do
  use Ecto.Migration

  def change do
    alter table(:user_session) do
      add :user_activity_type, :string
      remove :session_occurrence_id
      add :session_id, references(:session)
    end
  end
end
