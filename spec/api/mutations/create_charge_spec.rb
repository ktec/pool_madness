require "rails_helper"

RSpec.describe Mutations::CreateCharge do
  subject { Mutations::CreateCharge.field }
  let(:user) { create(:user) }
  let(:graphql_args) { GraphQL::Query::Arguments.new(input: args.merge(clientMutationId: "0")) }
  let(:graphql_context) { { current_user: user, current_ability: Ability.new(user) } }
  let(:graphql_result) { subject.resolve(nil, graphql_args, graphql_context) }

  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:tournament) { create(:tournament, :not_started) }
  let(:pool) { create(:pool, tournament: tournament) }
  let(:pool_id) { GraphQL::Relay::GlobalNodeIdentification.new.to_global_id("Pool", pool.id) }
  let!(:brackets) { create_list(:bracket, 2, :completed, user: user, pool: pool) }
  let!(:incomplete_bracket) { create(:bracket, user: user, pool: pool) }

  context "valid" do
    let(:args) { { pool_id: pool_id, token: stripe_helper.generate_card_token } }
    let(:charge) { graphql_result.result[:charge] }

    it "charges the credit card" do
      expect(charge["paid"]).to eq(true)
    end

    it "marks the brackets paid" do
      graphql_result
      brackets.each do |bracket|
        expect(bracket.reload).to be_paid
      end
    end

    it "does not pay for incomplete brackets" do
      graphql_result
      expect(incomplete_bracket.reload).to be_unpaid
    end

    it "includes the pool in result" do
      expect(graphql_result.result[:pool]).to eq(pool)
    end
  end

  context "stripe error" do
    let(:args) { { pool_id: pool_id, token: stripe_helper.generate_card_token } }

    before do
      StripeMock.prepare_card_error(:processing_error)
    end

    it "raises an error and does not mark brackets paid" do
      expect { graphql_result }.to raise_error(Stripe::CardError)
      brackets.each do |bracket|
        expect(bracket.reload).to be_unpaid
      end
    end
  end

  context "user outside of pool" do
    let(:pool_id) { GraphQL::Relay::GlobalNodeIdentification.new.to_global_id("Pool", create(:pool).id) }
    let(:args) { { pool_id: pool_id, token: stripe_helper.generate_card_token } }

    it "is not found" do
      expect { graphql_result }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
