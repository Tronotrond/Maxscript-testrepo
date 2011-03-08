global crcDebug = true
global partsArray = #()
global wcol = [120, 120, 120]  -- wirecolor
global camInheritance = 	#{1,2,3}
									--{POS_X,POS_Y,POS_Z,ROT_X,ROT_Y,ROT_Z,SCALE_X,SCALE_Y,SCALE_Z}




rollout crcRollout "Camera Rig Creator v0.1" width:300 height:300
(
	button btn1 "Create" pos:[20,39] width:170 height:55 enabled:true
	button btn2 "Rig" pos:[26,127] width:162 height:52 enabled:false
	on btn1 pressed do
	(
		-- should track mouse for placing rig in later version
		
		-- create rig
		partsArray[1] = box length: 50 	width: 50 	height: 5.0
		partsArray[2] = box length: 5.0 	width: 5.0 	height: 100
		partsArray[3] = box length: 5.0	width: 5.0	height: 150 pos:[0,0,(partsArray[2].height-(partsArray[2].height/5))]
		partsArray[3].pivot = [0, 0, partsArray[2].height]
		rotate partsArray[3] (angleaxis 90 [0,1,0])	-- rotate part 3 90 degrees for easy placement of next part
		partsArray[4] = box length: 5.0 	width: 5.0	height: 15 pos:[(partsArray[3].height-(partsArray[2].height/5)),0,partsArray[2].height]
		rotate partsArray[4] (angleaxis 180[0,1,0]) 	-- flip upside down
		partsArray[5] = dummy pos:[(partsArray[3].height-(partsArray[2].height/5)),0,(partsArray[2].height-(partsArray[4].height*2))]
		rotate partsArray[5] (angleaxis 180[0,1,0]) 	-- flip upside down
		partsArray[6] = targetcamera name:"rigCamera" pos:[(partsArray[3].height-(partsArray[2].height/5)),0,(partsArray[2].height-(partsArray[4].height*3))]
		rotate partsArray[6] (angleaxis -90 [0,0,1])	-- rotate camera
		rotate partsArray[6] (angleaxis -90 [0,1,0])
		
		setInheritanceFlags partsArray[4] camInheritance  -- set camera parent inheritance parameter
		setInheritanceFlags partsArray[5] camInheritance  -- set camera parent inheritance parameter

		for i in partsArray.count to 2 by -1 do
			partsArray[i].parent = partsArray[i-1]
				
		
		rotate partsArray[3] (angleaxis -45 [0,1,0])
		
		btn1.enabled = false
		btn2.enabled = true
		
		
		
		
			
	)
	
	on btn2 pressed  do
	(
		for a in 1 to partsArray.count do
		(
			
			if crcDebug == true then 
			(
				print a
			)
		)
		ikChain01 = IKSys.ikChain partsArray[2] partsArray[5] "IKHISolver"
	
	)
	
	
)



createDialog crcRollout 


----------- FLYTHROUGH SCRIPT --------------------

rollout FlythroughMaker "Flythrough Maker v1.0"
(
	local Obj		-- Circle storage
	local selDiam
	local selMin
	local selMax
		
	group "Circle Shape"
	(
		button createCircle "Create Circle Path" width:100
		spinner diam "Circle Diameter: " range:[1,10000,500] type:#integer enabled:false
		colorPicker wColor "Wire Color: " enabled:false
		
	)
	
	Button createCam "Create Camera and Link" width:150 enabled:false align:#center
	
	on diam changed val do (Obj.radius = (val/2))

	on createCircle pressed do 
		(
			-- get bounding box for selection to calculate radius
			if $ == undefined then -- if no selection
			(
				selDiam = [500,0,0]
				selMin = [0,0,0]
				selMax = [0,0,0]
			)
			else
			(
				selMin = $.min
				selMax = $.max
				selDiam = selMax - selMin -- calculate size of bounding box
				print selDiam -- print value for debug purposes
			)
					
			-- create a circle
			if Obj == undefined then
				Obj = Circle radius:selDiam[1] pos: (selMin +(selMax - selMin)/2.0) -- create a circle
			else
			(
				Obj.radius = selDiam[1]
				Obj.position = (selMin +(selMax - selMin)/2.0)
			)
			
			--Obj.position = selDiam
			wColor.enabled = true
			createCam.enabled = true
			diam.enabled = true
			Obj.render_renderable = false
			Obj.render_displayRenderMesh = true
			Obj.render_viewport_thickness = 5
			
		)
	on wColor changed val do Obj.wireColor = val			-- change wirecolor
	
	on createCam pressed do
	(
		flyCam = targetcamera()  									-- Create a camera
		camdummy = Dummy pos:Obj.position isSelected:on 	-- create lookat object for camera
		pc = path_constraint()											-- create a path constraint
		
		camdummy.lookat =flyCam									-- Camera lookat dummy
		
		flyCam.position.controller = pc 								-- assign path constraint to camera
		pc.path = Obj														-- set path constraint to circle
		
		
		
	)
	
	
)


	
	createDialog FlythroughMaker width:180