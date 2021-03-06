module Mutations
  AcceptInvitation = GraphQL::Relay::Mutation.define do
    name "AcceptInvitation"
    description "Join a pool with a given invite code"

    input_field :invite_code, !types.String

    return_field :pool, Queries::PoolType

    resolve lambda { |inputs, context|
      raise GraphQL::ExecutionError, "You must be signed in to view this information" if context[:current_user].blank?

      pool = Pool.find_by(invite_code: inputs[:invite_code].upcase)
      raise GraphQL::ExecutionError, "Invalid invite code" if pool.blank?

      pool.users << context[:current_user] unless pool.users.find_by(id: context[:current_user]).present?

      { pool: pool }
    }
  end
end
