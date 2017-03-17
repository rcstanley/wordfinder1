
local composer = require( "composer" )
composer.recycleOnSceneChange = true

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local backgroundImageURL = "graphics/background.png"
local selectPicImageURL = "graphics/clicktoselectpic.png"
local gameSnapshotFilename = "game_image.png"
local savedLettersKey = "saved_letters"
local gameImageKey = "game_image"
local alertTitle = "Alert"
local alertMessageNoContent = "Please Type at least 2 letters"
local fontSize1 = 30
local lettersTextBox
local clicktoselectpic 

--open the photo library and let the user pick a photo
-- save the photo to the 
local function getGameScreenShot()
	local function onPhotoComplete( event )
	   if ( event.completed ) then
	      local photo = event.target
	      local s = display.contentHeight / photo.height
	      photo:scale( s,s )
	      composer.gameImageKey = photo
	      display.save(photo,gameSnapshotFilename)
	      print( "photo w,h = " .. photo.width .. "," .. photo.height )
	   end
	end
 
	if media.hasSource( media.PhotoLibrary ) then
	   media.selectPhoto( { mediaSource = media.PhotoLibrary, listener = onPhotoComplete } )
	   
	else
	   native.showAlert( "Corona", "This device does not have a photo library.", { "OK" } )
	   composer.gameImageKey = clicktoselectpic
	end
end

--[[
get the text and picture and go to the next screen
--]]
local function continueToNextScene()
	local letters = lettersTextBox.text:rep(1)
	--make sure there are letters
	letters = letters:gsub("%A","")
	if (letters~=nil and letters:len() > 1) then
		letters = letters:lower()
		--native.showAlert(alertTitle,letters)
		composer.savedLettersKey =  letters
		composer.gotoScene( "scenefindWords" )
	else -- nothing was typed in the box
		native.showAlert(alertTitle,alertMessageNoContent)
	end

	--validate letters


end


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
	--listener to hide keyboard if background is tapped
	local function hideKeyboard()
		 native.setKeyboardFocus(nil)
	end
	background:addEventListener("tap",hideKeyboard)
	--load the "click to select image graphic"
	clicktoselectpic = composer.gameImageKey
	if(clicktoselectpic==nil) then
		clicktoselectpic = display.newImageRect( selectPicImageURL,450, 600 )
	end
	sceneGroup:insert(clicktoselectpic,0,10)
	--scale the image to fit 1/3 of the screen
	local s = (display.contentHeight/1.5) / clicktoselectpic.height
	clicktoselectpic:scale(s,s)
	clicktoselectpic.anchorX=0
	clicktoselectpic.anchorY=0
	clicktoselectpic.x = 0--clicktoselectpic.contentHeight/2
	clicktoselectpic.y = 10--clicktoselectpic.contentWidth/2
	
	composer.gameImageKey = clicktoselectpic

	--create a lable and a text box
	local letterTitle = display.newText( sceneGroup, "Letters:", display.contentCenterX, 75, native.systemFont, fontSize1-10 )
	letterTitle.anchorX=0
	 lettersTextBox = native.newTextField( display.contentCenterX+letterTitle.contentWidth, 75, 160, 40 )
	sceneGroup:insert( lettersTextBox )
	lettersTextBox.anchorX=0
	--if there are letters that have been saved before, put them in the text box
	local savedText = composer.savedLettersKey
	if(savedText~=nil and savedText:len()>0) then
		lettersTextBox.text = savedText
	end
	--value1:addEventListener( "userInput", textListener )
	--value1.inputType = "number"
	local deleteTextCircle = display.newCircle(sceneGroup,display.contentCenterX+letterTitle.contentWidth+160+20,75, 15)
	deleteTextCircle:setFillColor(.5,0,0)
	display.newText(sceneGroup,"X", display.contentCenterX+letterTitle.contentWidth+160+20,75,native.systemFont,fontSize1)
--create the selct button
	local selectButton = display.newText( sceneGroup, "Select Scene", display.contentCenterX, buttonY, native.systemFont, fontSize1 )
	selectButton:setFillColor( 1, 1, 1 )
	selectButton.anchorX=0
	selectButton.x = display.contentCenterX - selectButton.contentWidth
	 --create the continue button
	local continueButton = display.newText( sceneGroup, "Continue", display.contentCenterX, buttonY, native.systemFont, fontSize1 )
	continueButton.anchorX=0
	continueButton:setFillColor( 1, 1, 1 )
	continueButton.x = display.contentCenterX + continueButton.contentWidth
	
	--add event listeners
	selectButton:addEventListener( "tap", getGameScreenShot )
	continueButton:addEventListener( "tap", continueToNextScene )
	lettersTextBox:addEventListener("submitted",continueToNextScene)
	local function deleteText()
		lettersTextBox.text=""
		composer.savedLettersKey =  ""
	end
	deleteTextCircle:addEventListener("tap", deleteText)
	if clicktoselectpic~=nill then
		print(clicktoselectpic)
		clicktoselectpic:addEventListener("tap",getGameScreenShot)
	else
		print("clicktoselectpic is nill")
	end

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
		if lettersTextBox~=nil then
		lettersTextBox:removeSelf()
		--composer.removeScene("scenegetpicture")
	end

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
