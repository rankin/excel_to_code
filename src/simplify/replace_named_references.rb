class NamedReferences
  
  attr_accessor :named_references
  
  def initialize(refs)
    @named_references = {}
    refs.each do |line|
      sheet, name, reference = line.split("\t")
      @named_references[sheet.downcase] ||= {}
      @named_references[sheet.downcase][name.downcase] = eval(reference)
    end
  end
  
  def reference_for(sheet,named_reference)
    sheet = sheet.downcase
    named_reference = named_reference.downcase
    if @named_references.has_key?(sheet)
      @named_references[sheet][named_reference] || (@named_references[""] ? @named_references[""][named_reference] : nil) || [:error, "#NAME?"]
    else
      @named_references[""][named_reference] || [:error, "#NAME?"]
    end
  end
  
end

class ReplaceNamedReferencesAst
  
  attr_accessor :named_references, :default_sheet_name
  
  def initialize(named_references, default_sheet_name)
    @named_references, @default_sheet_name = named_references, default_sheet_name
  end
  
  def map(ast)
    return ast unless ast.is_a?(Array)
    operator = ast[0]
    if respond_to?(operator)
      send(operator,*ast[1..-1])
    else
      [operator,*ast[1..-1].map {|a| map(a) }]
    end
  end
  
  def sheet_reference(sheet,reference)
    if reference.first == :named_reference
      named_references.reference_for(sheet,reference.last)
    else
      [:sheet_reference,sheet,reference]
    end    
  end
  
  def named_reference(name)
    named_references.reference_for(default_sheet_name,name)
  end
  
end
  

class ReplaceNamedReferences
  
  attr_accessor :sheet_name
  
  def self.replace(values,sheet_name,named_references,output)
    self.new.replace(values,sheet_name,named_references,output)
  end
  
  # Rewrites ast with named references
  def replace(values,named_references,output)
    named_references = NamedReferences.new(named_references.readlines)
    rewriter = ReplaceNamedReferencesAst.new(named_references,sheet_name)
    values.lines do |line|
      # Looks to match shared string lines
      if line =~ /\[:named_reference/
        cols = line.split("\t")
        ast = cols.pop
        output.puts "#{cols.join("\t")}\t#{rewriter.map(eval(ast)).inspect}"
      else
        output.puts line
      end
    end
  end
end
