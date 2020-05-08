RSpec.describe "Devise Customizations", type: :request do
  let(:password) { SecureRandom.uuid }
  let(:email) { Faker::Internet.email }
  let(:user) { create(:user, email: email, password: password, password_confirmation: password) }

  describe "GET /register" do
    before { get "/register" }

    it "returns the registration page" do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("devise/registrations/new")
    end
  end

  describe "POST /login" do
    before do
      post "/login", params: { user: { email: email, password: user.password } }
    end

    it "logs a new user in" do
      expect(controller.current_user).to eq(user)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /account" do
    before { post "/account", params: params }

    let(:email) { Faker::Internet.email }
    let(:password) { SecureRandom.uuid }
    let(:params) { Hash(user: { email: email, password: password, password_confirmation: password }) }

    it "creates the user and redirects to home" do
      expect(response).to redirect_to(root_path)
      expect(controller.current_user.email).to eq(email)
    end
  end

  describe "PUT /account" do
    before do
      sign_in user
      put "/account", params: params
    end

    let(:email) { Faker::Internet.email }
    let(:params) { Hash(user: { email: email, current_password: password }) }

    it "creates the user and redirects to home" do
      expect(response).to redirect_to(edit_user_registration_path)
      expect(controller.current_user.email).to eq(email)
    end
  end

  describe "GET /account" do
    before do
      sign_in user
      get "/account"
    end

    it "returns the user edit page" do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("devise/registrations/edit")
    end
  end

  describe "DELETE /logout" do
    it "logs a new user in" do
      sign_in user

      delete "/logout"

      expect(controller.current_user).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end
end
