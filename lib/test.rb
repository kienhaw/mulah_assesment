[].empty?

arr = []
arr << { name: "haha" }
arr << { name: "hehe" }

a = arr.select {|x| x[:name] == "haha"}
puts a.first