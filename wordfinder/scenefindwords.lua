
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local backgroundImageURL = "graphics/background.png"

local tileImageURL = "graphics/tile.png"
local savedLettersKey = "saved_letters"
local gameImageKey = "game_image"
local letters
local listOfLetters={}
local numLetters
local useLowercase = true
local tileSize = 40
local fontSize1 = 40

local words = {}
--create a table representing each letter the user has typed in
local function createLetterTable(sceneGroup)
	listOfLetters = {}
	letters = (composer.savedLettersKey):rep(1)
	local letter
	local letterInfo={}
	local displayGroup
	local tileText
	local tileRec
	numLetters = letters:len()
	--sceneGroup.anchorX=0
	--local sceneGroup = self.view
	--for each letter the user submitted, create an image
	for i=1,numLetters do
		letter = string.sub(letters,i,i)
		local letterInfo={}
		letterInfo.letter=letter
		letterInfo.place = i
		displayGroup = display.newGroup()
		displayGroup.x = (tileSize+10) * i
		displayGroup.y = 0
		--displayGroup.anchorX = 0
		--display.newRect( displayGroup,0, 0, tileSize, tileSize )
		tileRec=display.newImageRect( displayGroup, tileImageURL, tileSize, tileSize )
		tileRec.anchorX = 0
		tileRec.x=0
		tileRec.y=0
		tileText = display.newEmbossedText(displayGroup,letter, tileSize,tileSize, native.systemFont,fontSize1)
		tileText:setFillColor(0,0,0)
		tileText.anchorX = .5
		tileText.x=tileSize/2
		tileText.y=0
		letterInfo.tile = displayGroup
		sceneGroup:insert(displayGroup)
		letterInfo.locked = false
		listOfLetters[i] = letterInfo 
		--print(letters.." "..i.." "..letter)
		--create and add a tile to the tilebar
	end
	
end

--load the list of valid words from the file
local function loadWords()
	-- Path for the file to read
	local path = system.pathForFile( "wordlist.txt", system.ResourceDirectory )
 
	-- Open the file handle
	local file, errorString = io.open( path, "r" )
 
	if not file then
	    -- Error occurred; output the cause
	    print( "File error: " .. errorString )
	else
	    -- Output lines
	    for line in file:lines() do
	    	line = line:lower();
	        words[line]=true
	    end
	    -- Close the file handle
	    io.close( file )
	end
	 
	file = nil
end

--local function place


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	--put in the background
	local background = display.newImageRect( sceneGroup, backgroundImageURL, display.actualContentWidth, display.actualContentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	--draw the screenshot image
	local screenshot = composer.gameImageKey
	sceneGroup:insert(screenshot)
	--draw the background for the tilebar
	local displayGroup = display.newGroup()
	local rec = display.newRect(displayGroup,0,0,display.actualContentWidth-50,50)--display.contentCenterX+10,display.actualContentHeight-60,display.actualContentWidth-50,50)
	sceneGroup:insert(displayGroup)
	displayGroup.x=display.contentCenterX+10
	displayGroup.y=display.actualContentHeight-60
	--get the string of letters the user entered
	createLetterTable(displayGroup)
	--load word dictionary
	loadWords()
end


-- shuffle the tiles
local function shuffle()
	end

-- check and see if the current tile configuration is a word
-- light up the check as green if it is
-- set the check to red if it isn't
local function checkTilesForWords()
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
