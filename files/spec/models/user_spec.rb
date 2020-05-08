RSpec.describe User, type: :model do
  describe "factories" do
    context "with the default factory" do
      subject(:user) { create(:user, email: email) }

      let(:email) { Faker::Internet.email }

      it "creates a user with valid attributes" do
        expect(user.email). to eq(email)
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive } # Devise
  end
end
