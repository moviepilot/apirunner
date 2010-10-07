class Checker

  @@children = []

  def initialize(testcase, response, excludes=nil)
    @testcase = testcase
    @response = response
    @excludes = excludes
  end

  # executes the checking routine and returns a result object
  # to be overwritten in child classes
  def check
    result = Result.new(@testcase, @response)
  end

  # returns a list of symbolized plugin names
  def self.available_plugins
    return @@children.map{ |child| child.to_s }
  end

  private

  # tracks all children of this class
  # this way plugins can be loaded automagically
  def self.inherited(child)
    @@children << child
  end

  # recursively parses the tree and returns a set of relative pathes
  # that can be used to match the both trees leafs
  def matcher_pathes_from(node, pathes = nil)
    pathes ||= []
    if not node.children.blank?
      node.children.each do |sub_node|
        matcher_pathes_from(sub_node, pathes)
      end
    else
      pathes << relative_path(node.parent.path)
    end
    pathes
  end

  # returns relative path for matching the target tree of the response body
  # explicit array adressing is replaced by *
  def relative_path(path)
    path.gsub(/\/([^\/]+)\[\d+\]\//i,"/*/")
  end

  # returns true if given attributes is an excluded item that does not have to be evaluated in this environment
  def excluded?(item)
    @excludes.include?(item)
  end

  # returns true if given string seems to be a regular expression
  def is_regex?(string)
    string.to_s.match(/^\/.+\/$/)
  end

  # returns true if the given regular expression matches the given value
  def regex_matches?(regex, value)
    regex = Regexp.compile( regex.gsub(/^\//, '').gsub(/\/$/,'') )
    !!value.to_s.match(regex)
  end

  # returns true if the given string exactly matches the given value
  def string_matches?(string, value)
    string.to_s == value.to_s
  end

  # parses output into JSON object
  def valid_json?(response_body)
    # responses may be nil, return true then
    return true if response_body.nil? or response_body = {}
    # returns true if given response is valid json, else false
    JSON.parse(response_body.to_s) rescue false
  end

end
