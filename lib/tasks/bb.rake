namespace :bb do
  
  BB_DIR = File.join(Rails.root, "beagle")
  JS_DIR = File.join(BB_DIR, "js")
  BB_REMOTE_DIR = File.join(Rails.root, "../beagle_mnt")
  
  task :build do
    Dir.chdir BB_DIR
    FileUtils.rm_r JS_DIR if File.exist? JS_DIR
    puts `coffee --compile --bare --output js/ coffee/`
  end
  
  task :deploy do 
    source = File.join(BB_DIR, "js")
    target = File.join(BB_REMOTE_DIR, "js")
    FileUtils.rm_r(target) if Dir.exists? target
    FileUtils.cp_r(source, target)    
  end
  
  task :cd => [:build, :deploy]
  
end
