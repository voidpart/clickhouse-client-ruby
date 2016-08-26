require 'will_paginate/collection'

module Clickhouse::Query::WillPaginate
  attr_accessor :current_page

  def page(options={})
    page = options[:page]
    per_page = options[:per_page] || WillPaginate.per_page

    per_page = per_page.to_i
    page = page.to_i

    rel = self.limit(per_page).offset((page-1)*per_page)
    rel.current_page = page
    rel.result.result_hash[:total_entries] = options[:total_entries].to_i if options[:total_entries].present?
    rel
  end

  def to_a
    return super unless current_page
    WillPaginate::Collection.create(current_page, limit_value, total_entries) do |pager|
      pager.replace super
    end
  end

  def to_h(*args)
    return super unless current_page
    WillPaginate::Collection.create(current_page, limit_value, total_entries) do |pager|
      pager.replace super
    end
  end

  def total_entries
    result.result_hash[:total_entries] ||= subquery_count
    result.total_entries 
  end
end
