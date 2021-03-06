module GeoGit
  class Repository
    attr_accessor :repo_path, :geogit
    
    def initialize(repo_path)
      @repo_path = repo_path
    end

    def geogit
      @geogit ||= GeoGit::Instance.new(@repo_path).instance
    end

    def close
      unless @geogit.nil?
        @geogit.close
        @geogit = nil
      end
    end

    def log
      GeoGit::Command::Log.new(geogit, @repo_path).run
    ensure
      close
    end

    def create_or_init
      GeoGit::Command::Init.new(geogit, @repo_path).run
      close
    end
    
    def add_and_commit
      repo_trees.each do |tree|
        add(tree)
        commit(tree)
      end
      geogit.close
    end
    
    def add(tree)
      tree_paths(tree).each do |tree_path|
        GeoGit::Command::FastAdd.new(geogit, @repo_path, tree_path).run
      end
    end
    
    def commit(tree)
      tree_paths(tree).each do |tree_path|
        GeoGit::Command::FastCommit.new(geogit, @repo_path, "imported_#{tree_path}").run
      end
    end
    
    def tree_paths(tree)
      repo_tree_path(tree).collect { |path| "#{tree}/#{path}" }
    end
    
    private
    
      def repo_trees
        GeoGit::Command::Tree.new(@repo_path).run
      end
    
      def repo_tree_path(tree)
        GeoGit::Command::Tree.new(@repo_path, tree).run
      end
  end
end

