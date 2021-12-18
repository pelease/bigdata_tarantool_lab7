function create()
	box.cfg{}
	userlog = box.schema.create_space(
    	'userlog',
    	{
        	format = {
          		{ name = "Day", type = 'number'},
          		{ name = "TickTime", type = 'number'},
          		{ name = "Speed", type = 'number'}
        	}, if_not_exists = true
    	}
	)

	userlog:create_index('primary',{
    		parts = {'Day','TickTime','Speed'},
    		unique=true,
    		type='TREE',
    		if_not_exists = true
	})

	userlog:create_index('ticktime_idx',{
      		parts = {'TickTime'},
      		unique=false,
      		type='TREE',
      		if_not_exists = true
	})


	userlog:create_index('speed_idx',{
     		 parts = {'Speed'},
    		  unique=false,
  		    type='TREE',
      		if_not_exists = true
	})
end

function connect()

	local mqtt = require('mqtt')
	local json = require('json')




	connect = mqtt.new("client_id100", true)

	connect:login_set('Hans', 'Test')

	connect:connect({host='194.67.112.161', port=1883})

	connect:on_message(function (message_id, topic, payload, gos, retain)
  	local data = json.decode(payload)
  		box.space.userlog:insert({data.Day, data.TickTime, data.Speed})
  		print('speed: ', data.Speed)
	end)
	connect:subscribe('v8')
end

function count()

	local count         = box.space.userlog:count()
	local median        = box.space.userlog.index.speed_idx:select({},{
                                                offset=math.floor(count/2), limit=1, iterator = EQ
                                                })[1].Speed
	local minTick       = box.space.userlog.index.ticktime_idx:min().TickTime
	local maxTick       = box.space.userlog.index.ticktime_idx:max().TickTime

	print('count: ',count)
	print('median: ', median)
	print('minTick: ', minTick)
	print('maxTick: ', maxTick)
end
