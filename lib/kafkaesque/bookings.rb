module Kafkaesque
  class Bookings
    VAT = Hash[
      :at => 0.19,
      :be => 0.19,
      :bg => 0.19,
      :cy => 0.19,
      :cz => 0.19,
      :de => 0.19,
      :dk => 0.19,
      :ee => 0.19,
      :es => 0.19,
      :fi => 0.19,
      :fr => 0.19,
      :gb => 0.19,
      :hu => 0.19,
      :ie => 0.19,
      :it => 0.19,
      :lt => 0.19,
      :lu => 0.19,
      :lv => 0.19,
      :mt => 0.19,
      :nl => 0.19,
      :no => 0.19,
      :pl => 0.19,
      :pt => 0.19,
      :ro => 0.19,
      :se => 0.19,
      :si => 0.19,
      :sk => 0.19
    ]
    # https://wooga.beanstalkapp.com/global_reporting_tracking/browse/stored_procedures/trunk/add_or_update_day_to_aggregated_users.sql
    #
    # -- calculate margin_estmate_usd (
    # -- formula is: fbc/10 * 1 / 1.19 - fbc / 10 * 0.3
    # -- the "1.19" value depends on the tax of the country
    # -- "0.3" is the fb revenue share
    #
    # set t.bookings_real_usd = (t.gross_sales_fbcredits/10 * 1/(1+IFNULL(c.sales_tax,0)) - t.gross_sales_fbcredits*0.03)
    def self.calculate(credits, country)
      vat = (country && VAT[country.to_sym]) || 0.0
      round((credits / 10.0) * (1.0 / (1 + vat)) - (credits * 0.03))
    end

    def self.round(money)
      (money * 100.0).round / 100.0
    end
  end
end