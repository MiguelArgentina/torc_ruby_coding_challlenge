require 'minitest/autorun'
require_relative 'receipt_generator'
describe ReceiptGenerator do

  describe "when help is asked" do
    it "should show the help for users" do
      help_text = ReceiptGenerator.help
      assert_includes(help_text, "Welcome to ReceiptGenerator!")
    end
  end

  describe "when user sends invalid input" do
    it "should raise an error if the quantity is not a number" do
      items = [['1',false,'box of chocolates',10.00, 'food']]
      error = assert_raises  { ReceiptGenerator.generate_receipt(items) }
      assert_match /Quantity must be an integer/, error.message
    end
    it "should raise an error if the imported is neither true nor false" do
      items = [[1,nil,'box of chocolates',10.00, 'food']]
      error = assert_raises  { ReceiptGenerator.generate_receipt(items) }
      assert_match /Imported must be true or false/, error.message
    end
    it "should raise an error if the name of the item is not a string" do
      items = [[1,true,4343,10.00, 'food']]
      error = assert_raises  { ReceiptGenerator.generate_receipt(items) }
      assert_match /Name must be a string/, error.message
    end
    it "should raise an error if the category passed in is not defined" do
      items = [[1,true,"box of chocolates",10.00, 'not defined']]
      error = assert_raises  { ReceiptGenerator.generate_receipt(items) }
      assert_match /Category must be one of/, error.message
    end
  end

end

