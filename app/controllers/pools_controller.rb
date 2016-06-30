class PoolsController < ApplicationController
  before_action :authenticate_user!

  def join
    @pool = Pool.find_by(invite_code: params[:invite_code].to_s.upcase)

    if @pool.present?
      @pool.users << current_user unless @pool.users.find_by(id: current_user).present?
      flash[:success] = "Successfully joined #{@pool.name} Pool"
      redirect_to pools_path
    else
      flash[:error] = "Invalid code entered"
      redirect_to invite_code_path
    end
  end
end
