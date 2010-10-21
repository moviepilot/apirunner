require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'testcase' do
  describe 'explode_iterations' do
    it 'should explode iterations if iterations is set to a proper value' do
      yaml_fixture = [{"name"=>"Create new User", "iterations" => "10", "request"=>{"headers"=>{"Content-Type"=>"application/json"}, "path"=>"/users/duffyduck@@", "method"=>"PUT", "body"=>{"username"=>"duffyduck", "watchlist"=>["m1035", "m2087"], "blacklist"=>["m1554", "m2981"], "skiplist"=>["m1590", "m1056"], "ratings"=>{"m12493"=>4.0, "m1875"=>2.5, "m7258"=>3.0, "m7339"=>4.0, "m3642"=>5.0}, "expires_at"=>"2011-09-10 00:41:50 +0200"}}, "response_expectation"=>{"status_code"=>201, "headers"=>{"Last-Modified"=>"/.*/"}, "body"=>{"username"=>"duffyduck", "watchlist"=>["m1035", "m2087"], "blacklist"=>["m1554", "m2981"], "skiplist"=>["m1590", "m1056"], "ratings"=>{"m12493"=>4.0, "m1875"=>2.5, "m7258"=>3.0, "m7339"=>4.0, "m3642"=>5.0}, "fsk"=>"18"}}}]
      Testcase.send(:explode_iterations,yaml_fixture).size.should == 10
      Testcase.send(:explode_iterations,yaml_fixture).map{ |x| x['request']['path']}.sort.should == ["/users/duffyduck0000001","/users/duffyduck0000002","/users/duffyduck0000003","/users/duffyduck0000004","/users/duffyduck0000005","/users/duffyduck0000006","/users/duffyduck0000007","/users/duffyduck0000008","/users/duffyduck0000009","/users/duffyduck0000010",]
    end
    it 'should not explode iterations if iterations is not set' do
      yaml_fixture = [{"name"=>"Create new User", "request"=>{"headers"=>{"Content-Type"=>"application/json"}, "path"=>"/users/duffyduck@@", "method"=>"PUT", "body"=>{"username"=>"duffyduck", "watchlist"=>["m1035", "m2087"], "blacklist"=>["m1554", "m2981"], "skiplist"=>["m1590", "m1056"], "ratings"=>{"m12493"=>4.0, "m1875"=>2.5, "m7258"=>3.0, "m7339"=>4.0, "m3642"=>5.0}, "expires_at"=>"2011-09-10 00:41:50 +0200"}}, "response_expectation"=>{"status_code"=>201, "headers"=>{"Last-Modified"=>"/.*/"}, "body"=>{"username"=>"duffyduck", "watchlist"=>["m1035", "m2087"], "blacklist"=>["m1554", "m2981"], "skiplist"=>["m1590", "m1056"], "ratings"=>{"m12493"=>4.0, "m1875"=>2.5, "m7258"=>3.0, "m7339"=>4.0, "m3642"=>5.0}, "fsk"=>"18"}}}]
      Testcase.send(:explode_iterations, yaml_fixture).size.should == 1
      Testcase.send(:explode_iterations, yaml_fixture).should eql yaml_fixture
    end
  end
end
