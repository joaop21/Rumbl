defmodule Rumbl.UserController do
    use Rumbl.Web, :controller

    plug :authenticate_user when action in [:index, :show]

    def index(conn, _params) do
        users = Repo.all(Rumbl.User)
        render conn, "index.html", users: users
    end

    def show(conn, %{"id" => id}) do
        user = Repo.get(Rumbl.User, id)
        render conn, "show.html", user: user
    end

    alias Rumbl.User

    def new(conn, params) do
        changeset = User.changeset(%User{}, params)
        render conn, "new.html", changeset: changeset
    end

    def create(conn, %{"user" => user_params}) do
        changeset = User.registration_changeset(%User{}, user_params)
        case Repo.insert(changeset) do
            {:ok, user} ->
                conn
                |> Rumbl.Auth.login(user)
                |> put_flash(:info, "#{user.name} created!")
                |> redirect(to: user_path(conn, :index))
            {:error, changeset} ->
                render(conn, "new.html", changeset: changeset)
        end
    end
end
