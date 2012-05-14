module Kafkaesque
  class Bookings
    VAT = Hash[
      :at => 0.149,
      :be => 0.149,
      :bg => 0.149,
      :cy => 0.149,
      :cz => 0.149,
      :de => 0.149,
      :dk => 0.149,
      :ee => 0.149,
      :es => 0.149,
      :fi => 0.149,
      :fr => 0.149,
      :gb => 0.149,
      :gr => 0.149,
      :hu => 0.149,
      :ie => 0.149,
      :it => 0.149,
      :lt => 0.149,
      :lu => 0.149,
      :lv => 0.149,
      :mt => 0.149,
      :nl => 0.149,
      :pl => 0.149,
      :pt => 0.149,
      :ro => 0.149,
      :se => 0.149,
      :si => 0.149,
      :sk => 0.149,
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
