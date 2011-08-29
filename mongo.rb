class Mongo
  def self.menu bucket=nil
    "
    - .collections/
    ".unindent
  end

  def self.collections collection=nil

    collection.sub!(/\/$/, '') if collection

    if collection
      return Mongo.run("db.#{collection}.find()").gsub(/^/, '| ')
    end

    json = Mongo.run 'printjson(db._adminCommand("listDatabases"))'
    o = JSON[json]
    o["databases"].map{|d| "#{d['name']}/"}

  end

  def self.run command
    command << ".forEach(printjson)" if command =~ /.find\(/
    txt = `mongo --eval '#{command}'`
    txt.sub /(.+\n){3}/, ''   # Delete first 3 lines
  end

  def self.init

    LineLauncher.add(/^ *db\./) do |l|   # General db... lines
      l.strip!
      txt = self.run l
      FileTree.insert_under "#{txt.strip}\n"
    end

    LineLauncher.add(:paren=>"mdb") do   # General db... lines

      l = Line.without_label

      l.strip!
      txt = self.run l
      FileTree.insert_under "#{txt.strip}\n"
    end

    LineLauncher.add(/^ *(\w+)\.(save|update)\(/) do |l|   # Shortcut for foo.save()
      l.strip!
      l = "db.#{l}"
      txt = self.run l
      FileTree.insert_under "done#{txt.strip}\n"
    end

    LineLauncher.add(/^ *(\w+)\.find\(/) do |l|   # Shortcut for foo.find()
      l.strip!
      l = "db.#{l}"
      txt = self.run l
      FileTree.insert_under "#{txt.strip}\n"
    end

    LineLauncher.add(/^ *(\w+)\.remove\(/) do |l|   # Shortcut for foo.remove()
      l.strip!
      l = "db.#{l}"
      txt = self.run l
      FileTree.insert_under "#{txt.strip}\n"
    end

  end
end

Mongo.init
