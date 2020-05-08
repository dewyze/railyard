RSpec.describe HomeController, type: :request do
  describe "#home" do
    before { get "/" }

    it "is successful" do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end
end
