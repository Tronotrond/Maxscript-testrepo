rollout FlythroughMaker "Flythrough Maker v1.0"
(
		local Obj               -- Circle storage
		local selDial
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
							selDiam = selMax - selMin			-- calculate size of bounding box
							
							print selDiam                           -- print value for debug purposes
                       )


						if Obj == undefined then 
							Obj = Circle radius:selDiam[1] pos: (selMin +(selMax  - selMin)/2.0)         -- create a circle
                       else
						(
							Obj.radius = selDiam[1]
							Obj.position = (selMin +(selMax  - selMin)/2.0) 							
						)
						--Obj.position = selDiam
                       wColor.enabled = true
                       createCam.enabled = true
                       --createCircle.enabled = false
                       diam.enabled = true
                       Obj.render_renderable = false
                       Obj.render_displayRenderMesh = true
                       Obj.render_viewport_thickness = 5

               )
       on wColor changed val do Obj.wireColor = val                   		 -- change wirecolor

       on createCam pressed do
       (
               flyCam = targetcamera()                               			-- Create a camera
               camdummy = Dummy pos:Obj.position isSelected:on  		-- create lookat object for camera
               pc = path_constraint()                                  			-- create a path constraint

               camdummy.lookat =flyCam                          				-- Camera lookat dummy

               flyCam.position.controller = pc                                   	-- assign path constraint to camera
               pc.path = Obj	                                                    	-- set path constraint to circle
			   pc.loop = true



       )


)



       createDialog FlythroughMaker width:180