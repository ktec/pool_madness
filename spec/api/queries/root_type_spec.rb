require "rails_helper"

RSpec.describe Queries::RootType do
  subject { Queries::RootType }

  context "fields" do
    let(:fields) { %w(node lists pool) }

    it "has the proper fields" do
      expect(subject.fields.keys).to match_array(fields)
    end
  end

  context "pool" do
    subject { Queries::RootType.fields["pool"] }
    let!(:user) { create :user }
    let(:ability) { Ability.new(user) }
    let!(:pool_users) { create_list :pool_user, 3, user: user }
    let(:pools) { user.reload.pools }
    let(:pool) { pools.shuffle.pop }
    let(:args) { { "model_id" => pool.id } }

    context "signed in" do
      it "is a pool" do
        expect(subject.resolve(nil, args, current_user: user, current_ability: ability)).to eq(pool)
      end
    end

    context "not signed in" do
      it "is a graphql execution error" do
        result = subject.resolve(nil, args, {})
        expect(result).to be_a(GraphQL::ExecutionError)
        expect(result.message).to match(/must be signed in/i)
      end
    end
  end
end
