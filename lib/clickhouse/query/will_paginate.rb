require 'will_paginate/collection'

module Clickhouse::Query::WillPaginate
  attr_accessor :current_page
  
  def page(options={})
    page = options[:page]
    per_page = options[:per_page]
    total = options[:total_entries]

    per_page = per_page.to_i
    page = page.to_i

    rel = self.limit(per_page).offset((page-1)*per_page)
    rel.current_page = page
    rel
  end

  def to_a
    return super unless current_page
    WillPaginate::Collection.create(current_page, limit_value, total_entries) do |pager|
      pager.replace super
    end
  end
end
