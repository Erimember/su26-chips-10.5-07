# frozen_string_literal: true

class BillsController < ApplicationController
  before_action :set_bill, only: %i[show]

  # GET /bills or /bills.json
  def index
    @bills = Bill.all
  end

  # GET /bills/1 or /bills/1.json
  def show; end

  # POST /bills or /bills.json
  def create
    @bill = Bill.new(bill_params)

    respond_to do |format|
      if @bill.save
        format.html { redirect_to @bill, notice: 'Bill was successfully created.' }
        format.json { render :show, status: :created, location: @bill }
      else
        format.html { redirect_to bills_path, alert: 'Bill could not be saved.' }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_bill
    @bill = Bill.find(params[:id])
  end

  def bill_params
    params.require(:bill).permit(:title, :congress, :number, :original_chamber, :type, :summary)
  end
end
