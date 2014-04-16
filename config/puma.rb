workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 12)

preload_app!

rackup                DefaultRackup
#port                 ENV['port_cbmodels'] || 3001
daemonize             true
bind                  "unix:///www/run/cbu.sock"
pidfile               '/www/run/cbu.pid'           
stdout_redirect       "/www/log/puma-cbu-stdout.log", "/www/log/puma-cbu-stderr.log"
environment           ENV['env_cbu'] || 'production'  

#control app considered broken right now (puma github)
#activate_control_app  "unix:///www/run/cbuctl.sock"

#state file considered broken right now (puma github)
#state_path            "/www/run/cbu.state"

on_worker_boot do
	require 'dotenv'
	Dotenv.load! ".env"  
	puts ENV['cbu_couchbase_servers']

	CBU = Couchbase.new(bucket: "cbu", node_list: ENV['cbu_couchbase_servers'].split(","))
	CBD = Couchbase.new(bucket: "cbdocs", node_list: ENV['cbu_couchbase_servers'].split(","))

	CBU.quiet = true
	CBD.quiet = true 
end