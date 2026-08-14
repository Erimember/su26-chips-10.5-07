# frozen_string_literal: true

class BillsController < ApplicationController
  before_action :set_bill, only: %i[show]

  BILL_TYPES = %w[hr s hjres sjres hconres sconres hres sres].freeze

  # GET /bills — searches the congress.gov API (Task 2.4)
  def index
    result = fetch_bills
    @bills = result['bills'] || []
    @shown_count = @bills.length
    @total_count = result.dig('pagination', 'count') || @shown_count
  end

  # GET /bills/1
  def show; end

  # POST /bills — saves a bill, fetching its summary from the API (Task 2.6)
  def create
    @bill = Bill.new(bill_params)
    @bill.summary = fetch_summary(@bill) if @bill.summary.blank?

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

  def fetch_bills
    if params[:bill_type].present? && params[:congress].blank?
      flash.now[:alert] = 'A congress number is required when searching by bill type.'
      return recent_bills
    end

    return recent_bills if params[:congress].blank?

    congress_client.bills(congress: params[:congress], type: params[:bill_type].presence || 'all', limit: 50).get
  rescue Congress::Error => e
    flash.now[:alert] = "congress.gov API error: #{e.message}"
    { 'bills' => [] }
  end

  def recent_bills
    congress_client.bills(sort: 'updateDate+desc', limit: 50).get
  end

  # The summary lives at a separate /summaries endpoint; take the latest
  # version by actionDate and strip the HTML before storing (Task 2.6).
  def fetch_summary(bill)
    return '' unless summary_lookup_possible?(bill)

    result = congress_client.summaries(congress: bill.congress,
                                       bill_type: bill.type.to_s.downcase,
                                       bill_number: bill.number)
    latest = (result['summaries'] || []).max_by { |s| s['actionDate'].to_s }
    return '' if latest.nil?

    ActionView::Base.full_sanitizer.sanitize(latest['text']).to_s.gsub('&nbsp;', ' ').squish
  rescue Congress::Error
    ''
  end

  def summary_lookup_possible?(bill)
    [bill.congress, bill.type, bill.number].all?(&:present?)
  end

  def congress_client
    @congress_client ||= Congress::Client.new(Rails.application.credentials[:CONGRESS_GOV_API_KEY])
  end

  def set_bill
    @bill = Bill.find(params[:id])
  end

  def bill_params
    params.require(:bill).permit(:title, :congress, :number, :original_chamber, :type, :summary)
  end
end
