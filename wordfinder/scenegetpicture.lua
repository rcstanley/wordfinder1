
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local backgroundImageURL = "graphics/background.png"
local selectPicImageURL = "graphics/clicktoselectpic.png"



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local buttonY = display.actualContentHeight - 80
	--load the background image
	local background = display.newImageRect( sceneGroup, backgroundImageURL, display.actualContentWidth, display.actualContentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	--load the "click to select image graphic"
	local clicktoselectpic = display.newImageRect( sceneGroup, selectPicImageURL,450, 600 )
	--scale the image to fit 1/3 of the screen
	local s = (display.contentHeight/1.5) / clicktoselectpic.height
	clicktoselectpic:scale(s,s)
	clicktoselectpic.anchorX=0
	clicktoselectpic.anchorY=0
	clicktoselectpic.x = 0--clicktoselectpic.contentHeight/2
	clicktoselectpic.y = 10--clicktoselectpic.contentWidth/2
	composer.setVariable("gameImage",clicktoselectpic)
	--local title = display.newImageRect( sceneGroup, "title.png", 500, 80 )
	--title.x = display.contentCenterX
	--title.y = 200
	--menu chocies
--create the selct button
	local selectButton = display.newText( sceneGroup, "Select", display.contentCenterX, buttonY, native.systemFont, 44 )
	selectButton:setFillColor( 1, 1, 1 )
	selectButton.x = display.contentCenterX - selectButton.contentWidth
	 --create the continue button
	local continueButton = display.newText( sceneGroup, "Continue", display.contentCenterX, buttonY, native.systemFont, 44 )
	continueButton:setFillColor( 1, 1, 1 )
	continueButton.x = display.contentCenterX + selectButton.contentWidth
	--listener for selecting screen shot
	local function onPhotoComplete( event )
	   if ( event.completed ) then
	      local photo = event.target
	      local s = display.contentHeight / photo.height
	      photo:scale( s,s )
	      composer.setVariable("gameImage", photo)
	      print( "photo w,h = " .. photo.width .. "," .. photo.height )
	   end
	end
 
	if media.hasSource( media.PhotoLibrary ) then
	   media.selectPhoto( { mediaSource = media.PhotoLibrary, listener = onPhotoComplete } )
	   
	else
	   native.showAlert( "Corona", "This device does not have a photo library.", { "OK" } )
	   composer.setVariable("gameImage",background)
	end
	
	--add event listeners
	--playButton:addEventListener( "tap", gotoGame )
	--continueButton:addEventListener( "tap", gotoHighScores )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
