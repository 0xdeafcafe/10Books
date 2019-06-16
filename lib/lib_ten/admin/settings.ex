defmodule LibTen.Admin.Settings do
  use Ecto.Schema
  use Arc.Ecto.Schema

  schema "settings" do
    field :logo, LibTen.Admin.SiteLogo.Type
    timestamps()
  end

  def changeset(settings, attrs) do
    settings
    |> cast_attachments(attrs, [:logo])
  end
end
