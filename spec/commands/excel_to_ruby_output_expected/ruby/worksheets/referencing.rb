# Referencing

require_relative '../examplespreadsheet'

module ExampleSpreadsheet
class Referencing < Spreadsheet
  def a1; "Named reference"; end
  def a2; referencing.a1; end
  attr_accessor :a4 # Default: 10
  def b4; add(a4,1); end
  def c4; add(b4,1); end
  def b8; referencing.a1; end
  def b9; sum([[tables.b5,tables.c5,nil]]); end

  def initialize
    @a4 = 10
  end

end
end
