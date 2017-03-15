
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
local isAWordCircle
local currentWord

local tileStartTable = {}
local words = {}
local autoCheck = false

--calculate where each tile/letter should go based on its location in the "word"
local function placeTile(tileInfo)
	tileInfo.x= ((tileSize)* (tileInfo.wf_place-1) ) + (10*tileInfo.wf_place)
	tileInfo.y=0
	return tileInfo.x
end

local function getLocation1(newX)
	--local i=1
	local x = newX + tileSize/2
	if x<tileStartTable[1] then 
		return 1
	end
	for i=1, numLetters-1 do
		if x >= tileStartTable[i] and x < tileStartTable[i+1] then
			if x>tileStartTable[i]+tileSize/2 then
				return i+1
			end
			return i
		end
	end
	
	return numLetters
end

-- check and see if the current tile configuration is a word
-- light up the check as green if it is
-- set the check to red if it isn't
local function checkTilesForWords()
	if words[letters]==true then
		isAWordCircle:setFillColor(0,.5,0)
	else 
		isAWordCircle:setFillColor(.5,0,0)
	end
end

--go through the list of tiles, renumber those that have changed 
-- because movedTile moved
-- change the x of those that have changed 
-- newloc>old loc bug
local function sortTiles(movedTile, oldLoc, newLoc)
	local mt = movedTile
	if(newLoc > oldLoc) then
		for i=oldLoc, newLoc-1 do
			if i< numLetters then
				listOfLetters[i]=listOfLetters[i+1]
				listOfLetters[i].wf_place = i
				listOfLetters[i].x = tileStartTable[i]
			end
		end
	elseif oldLoc > newLoc then
		local i = oldLoc
		while i > newLoc do
			if i>1 then
				listOfLetters[i]=listOfLetters[i-1]
				listOfLetters[i].wf_place = i
				listOfLetters[i].x = tileStartTable[i]
			end
			i = i-1
		end
	end
	listOfLetters[newLoc]=movedTile
	movedTile.wf_place = newLoc
	movedTile.x = tileStartTable[newLoc]
	--the word has changed, so recreate it
	local word =""
	for i=1, numLetters do
		word = word..listOfLetters[i].wf_letter
	end
	currentWord.text = word
	letters = word
	if(autoCheck) then
		checkTilesForWords()
	else --word has changed, so gray out the word
		isAWordCircle:setFillColor(.2,.2,.2)
	end
end


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
	local leftX 
	--for each letter the user submitted, create an image of a tile and a letter
	for i=1,numLetters do
		letter = string.sub(letters,i,i)
		displayGroup = display.newGroup()
		displayGroup.wf_letter=letter
		displayGroup.wf_place=i
		--calculate tile position
		tileRec=display.newImageRect( displayGroup, tileImageURL, tileSize, tileSize )
		tileRec.anchorX = 0
		tileRec.x=0
		tileRec.y=0
		tileText = display.newEmbossedText(displayGroup,letter, tileSize,tileSize, native.systemFont,fontSize1)
		tileText:setFillColor(0,0,0)
		tileText.anchorX = .5
		tileText.x=tileSize/2
		tileText.y=0
		--letterInfo.tile = displayGroup
		leftX = placeTile(displayGroup)
		--mark where the left edge of the tile is for placing tiles later
		tileStartTable[i]=leftX
		--listens for tap / drag with a tile
		-- if a tap then ask if you want it locked
		-- if a drag then have tile follow the drag
		-- if a release then insert the tile where it goes
		 function displayGroup:touch(event)
			 if event.phase == "began" then
				self:toFront()
		        self.markX = self.x    -- store x location of object
		       	self.markY = self.y    -- store y location of object
		        self.origX = self.x
		        self.origY = self.y
				display.getCurrentStage():setFocus( event.target )
		    elseif event.phase == "moved" then
			
		        local x = (event.x - event.xStart) + self.markX
		       -- local y = (event.y - event.yStart) + self.markY
		        
		        self.x, self.y = x, y    -- move object based on calculations above
		    elseif event.phase == "ended" then
		    	display.getCurrentStage():setFocus( nil )
		    	local loc = getLocation1(self.x)
		    	local oldLoc = self.wf_place
		    	--self.wf_place = loc
		    	--native.showAlert("alert","new location is "..loc.." old loc is "..oldLoc)
		    	sortTiles(self,oldLoc,loc)
		    -- put the letter where it goes in the new order
		    elseif event.phase == "cancelled" then
		    	--put the object back where it started
		    	self.x,self.y = self.origX,self.origY
		    	display.getCurrentStage():setFocus( nil )
		    end
		    
		    return true
		end
		displayGroup:addEventListener("touch",displayGroup)
		sceneGroup:insert(displayGroup)
		--letterInfo.locked = false
		displayGroup.wf_locked=false
		--listOfLetters[i] = letterInfo 
		listOfLetters[i] = displayGroup 
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
	--load word dictionary
	loadWords()

	local background = display.newImageRect( sceneGroup, backgroundImageURL, display.actualContentWidth, display.actualContentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	sceneGroup.anchorX=0
	sceneGroup.anchorY=0
	--draw the screenshot image
	local screenshot = composer.gameImageKey
	sceneGroup:insert(screenshot)
	
	--draw the background for the tilebar
	local displayGroup = display.newGroup()
	displayGroup.anchorX=0
	displayGroup.anchorY=0
	displayGroup.x=0--display.contentCenterX+10
	displayGroup.y=display.actualContentHeight-60
	--displayGroup.anchorChildren = true
	local rec = display.newRect(displayGroup,0,0,display.actualContentWidth-50,50)--display.contentCenterX+10,display.actualContentHeight-60,display.actualContentWidth-50,50)
	rec.anchorX=0
	--get the string of letters the user entered
	createLetterTable(displayGroup)
	sceneGroup:insert(displayGroup)

	currentWord = display.newText( sceneGroup, letters, display.contentCenterX+15, 75, native.systemFont, fontSize1-10 )
	currentWord.anchorX=0
	isAWordCircle=display.newCircle(sceneGroup,display.contentCenterX,75, 15)
	if(autoCheck) then
		checkTilesForWords()
	else
		isAWordCircle:setFillColor(.2,.2,.2)
	end
	isAWordCircle:addEventListener("tap",checkTilesForWords)
	
	
end


-- shuffle the tiles
local function shuffle()
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
