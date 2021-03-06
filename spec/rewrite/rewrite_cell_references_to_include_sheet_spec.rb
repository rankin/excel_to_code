require_relative '../spec_helper'

describe RewriteCellReferencesToIncludeSheet do
  
it "should take a file with ast in its last column and rewrite any [:cell, 'A1'] and [:area, 'A1', 'B2'] references to [:sheet_reference, 'sheet1', [:cell, 'A1']]" do
input = <<END
B2	[:function, "SUM", [:cell, "F4"]]
C2	[:function, "SUM", [:sheet_reference, "ValueTypes", [:area, "A3", "A4"]]]
B3	[:function, "SUM", [:area, "F1", "F6"]]
END

input = StringIO.new(input)
output = StringIO.new

r = RewriteCellReferencesToIncludeSheet.new
r.worksheet = "default"
r.rewrite(input,output)

expected =<<END
B2	[:function, "SUM", [:sheet_reference, "default", [:cell, "F4"]]]
C2	[:function, "SUM", [:sheet_reference, "ValueTypes", [:area, "A3", "A4"]]]
B3	[:function, "SUM", [:sheet_reference, "default", [:area, "F1", "F6"]]]
END
output.string.should == expected

end

end
