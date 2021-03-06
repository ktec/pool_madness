class UpdatePossibleOutcomesJob < ActiveJob::Base
  queue_as :default

  def perform(tournament_id, opts = {})
    opts = HashWithIndifferentAccess.new(update_db: true).merge(opts)

    timestamp = Time.now.to_i
    outcome_set_key = self.class.outcome_set_key(tournament_id, timestamp)

    Sidekiq.redis { |redis| redis.set outcome_set_key, -1 }

    5.times { CalculatePossibleOutcomeJob.perform_later(tournament_id, timestamp, opts) }
  end

  def self.outcome_set_key(tournament_id, timestamp)
    "outcomeset_#{tournament_id}_#{timestamp}"
  end
end
