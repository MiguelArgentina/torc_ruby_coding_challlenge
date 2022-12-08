# Class that processes buying lists and generates a receipt containing taxes
class ReceiptGenerator
  EXAMPLE_INPUT = [
    [1,true,'box of chocolates',10.00, 'food'],
    [1,true,'bottle of perfume',47.50, 'other']
  ]

  IMPORT_TAX = 0.05
  SALES_TAX = 0.10
  EXEMPT_CATEGORIES = %w[book food medical].freeze
  ROUNDUP_TO_NEAREST = 0.05

  HELP_TEXT = <<HEREDOC
  Welcome to ReceiptGenerator!
  - ReceiptGenerator.help: this menu
  - ReceiptGenerator.generate_receipt(items): generate a receipt for the given items

  - Valid input:
      + An array of receipt items: [receipt_item_1, receipt_item_2, ...]
      + ReceiptItems must comply with this format: [quantity, imported, name, price, category], where:
        * quantity: integer
        * imported: true if imported, false for local goods
        * name: string
        * price: float, 2 decimals. 12.45 is a valid price. Prices will be rounded to 2 decimals.
        * category: string, one of the following: #{EXEMPT_CATEGORIES.join(', ')}, other

  Example input:
  #{EXAMPLE_INPUT}
HEREDOC

  class << self
    def help
      puts HELP_TEXT
      HELP_TEXT
    end

    def generate_receipt(items)
      raise 'Invalid input. Call ReceiptGenerator.help for more info' unless valid_input?(items)
      sales_taxes, total_amount, processed_items = process items
      puts ""
      puts "*"*80
      puts ""
      puts "Generated receipt:"
      puts ""
      processed_items.each{|item| pp item}
      puts "Sales Taxes: #{sales_taxes}"
      puts "Total: #{total_amount}"
    end


    private

    def process items
      sales_taxes = 0
      total_amount = 0
      processed_items = []
      items.each do |item|
        quantity, imported, name, price, category = item
        sales_tax = 0
        import_tax = 0
        import_tax = rounded_to_nearest(price * IMPORT_TAX) if imported
        sales_tax += rounded_to_nearest(price * SALES_TAX) unless EXEMPT_CATEGORIES.include?(category)
        sales_taxes += sales_tax + import_tax
        total_price_for_item = price + sales_tax + import_tax
        total_amount += quantity * total_price_for_item
        result = Presenters::ReceiptItemPresenter.new(quantity, imported, name, total_price_for_item)
        processed_items << result.to_s
      end
      [sales_taxes.round(2), total_amount, processed_items]
    end

    def rounded_to_nearest value
      ((value * (1 / ROUNDUP_TO_NEAREST)).round / (1.00 / ROUNDUP_TO_NEAREST)).round(2)
    end

    def valid_input?(input)
      input.each do |item|
        item.is_a?(Array) or raise ArgumentError.new("Each item must be an array, Got #{item.class}.")
        item.size == 5 or raise ArgumentError.new("Each item must have 5 elements. Got #{item.size}.")
        item[0].is_a?(Integer) or raise ArgumentError.new("Quantity must be an integer. Got #{item[0].class}.")
        [true, false].include?(item[1]) or raise ArgumentError.new("Imported must be true or false. Got #{item[1].class}.")
        item[2].is_a?(String) or raise ArgumentError.new("Name must be a string. Got #{item[2].class}.")
        item[3].is_a?(Numeric) or raise ArgumentError.new("Price must be a number. Got #{item[3].class}.")
        (EXEMPT_CATEGORIES + ["other"]).include?(item[4]) or raise ArgumentError.new("Category must be one of [#{EXEMPT_CATEGORIES.join(', ')}, other]. Got #{item[4]}.")
      end
      true
    end
  end

  module Presenters
    class ReceiptItemPresenter
      def initialize(quantity, imported, name, total_price_for_item)
        @quantity = quantity
        @name = name
        @imported = imported
        @total_price_for_item = total_price_for_item
      end
      def to_s
        [@quantity, @imported ? 'imported' : '',@name, (@quantity * @total_price_for_item).round(2)].join(' ')
      end
    end
  end
end

input_1 = [
  [2,false,'book',12.49, 'book'],
  [1,false,'music CD',14.99, 'other'],
  [1,false,'chocolate bar',0.85, 'food']
]

input_2 = [
  [1,true,'box of chocolates',10.00, 'food'],
  [1,true,'bottle of perfume',47.50, 'other']
]

input_3 = [
  [1,true,'bottle of perfume',27.99, 'other'],
  [1,false,'bottle of perfume',18.99, 'other'],
  [1,false,'packet of headache pills',9.75, 'medical'],
  [3,true,'box of chocolates',11.25, 'food']
]

ReceiptGenerator.help
ReceiptGenerator.generate_receipt(input_1)
ReceiptGenerator.generate_receipt(input_2)
ReceiptGenerator.generate_receipt(input_3)
