
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
-- table of display groups w/ a few extra variables added
local listOfLetters={}
local numLetters = 0
local useLowercase = true
local tileSize = 40
local fontSize1 = 40
local fontSize2 = 20
local isAWordCircle
local currentWord

local tileStartTable = {}
local words = {}
local autoCheck = true

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

local function recreateWord()
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

--insert a Tile into a linked list at the place indicated
local function insertTile(movedTile,tileList,newPlace)
	local i=1
	local linkedList
	if newPlace<=1 then
		linkedList = {next=tileList,tile=movedTile}
		--print("adding a node at place "..newPlace)
	else
		linkedList = tileList
		local currentNode = tileList
		while currentNode~=nil and i<=numLetters do 
			if i==newPlace-1 then
				--print("adding a node at place "..newPlace)
				-- attach the next node to the moved node
				local temp = {next=currentNode.next,tile=movedTile}
				-- make the moved node the next node
				currentNode.next = temp
				break
			end
			currentNode = currentNode.next
			i=i+1
		end
	end
	return linkedList
end

--converts a linkled list of tiles back to the array
local function linkedListToArray(regularTiles)
	local currentTile = regularTiles
	local i = 1
	while i <= numLetters and currentTile~=nil do
		--print("i="..i.." letter="..currentTile.tile.wf_letter)
		listOfLetters[i] = currentTile.tile
		if listOfLetters[i]~=nil then
			listOfLetters[i].wf_place = i
			listOfLetters[i].x = tileStartTable[i]
		end
		i = i+1
		currentTile = currentTile.next
	end
end

--helper function to print out a linked list for debugging
local function printList(linkedList)
	local i = 1
	local currentTile = linkedList
	local tile
	if linkedList == nil then
		print("the list is empty")
		return
	end
	while currentTile~=nil do
		tile = currentTile.tile
		if tile~=nil then
			print("at "..i.." the letter is "..tile.wf_letter)
		else
			print("at "..i.." the letter is nil")
		end
		currentTile = currentTile.next
		i=i+1
	end
end

--function to insert a moved tile
--make a linked list of static/locked tiles
-- make linked list of other tiles
-- delete the moved tile
--insert the moved tile
--reinsert the locked tiles

local function moveTile(movedTile,oldLoc,newLoc )
	local lockedTiles = nil
	local regularTiles = nil
	local i = numLetters
	local newPlace = newLoc

	--check that the current tile isn't locked and that the new location isn't locked
	if listOfLetters[oldLoc].wf_locked then
		return
	end
	--make a linked list of the locked tiles
	while i>=1 do
		if listOfLetters[i].wf_locked then

			lockedTiles = {next=lockedTiles,tile = listOfLetters[i]}
			if i<newPlace then
			
				newPlace = newPlace - 1
			end
		else
			--add the tile to the list of regular tiles
			if listOfLetters[i]~=movedTile then
				regularTiles = {next=regularTiles,tile=listOfLetters[i]}
			end
		end
		i=i-1
	end

	--insert the moved tile into the list
	regularTiles = insertTile(movedTile,regularTiles,newPlace)
	--insert the Locked Tiles
	local currentTile = lockedTiles
	while currentTile~=nil do
		insertTile(currentTile.tile,regularTiles,currentTile.tile.wf_place)
		currentTile = currentTile.next
	end
	--redo the array of Letters
	linkedListToArray(regularTiles)
	-- redo the word
	recreateWord()
	--print("word is "..letters)
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
		 	--don't move the tile if locked
		 	if self.wf_locked ~=nil and self.wf_locked == true then
		 		--native.showAlert("alert", "tile is locked")
		 		return true
		 	end
			 if event.phase == "began" then
				self:toFront()
		        self.markX = self.x    -- store x location of object
		       	self.markY = self.y    -- store y location of object
		        self.origX = self.x
		        self.origY = self.y
				display.getCurrentStage():setFocus( event.target )
		    elseif event.phase == "moved" then
		    	if self.markX==nil then return true end
			    local x = (event.x - event.xStart) + self.markX
		       -- local y = (event.y - event.yStart) + self.markY
		        
		        self.x, self.y = x, y    -- move object based on calculations above
		    elseif event.phase == "ended" then
		    	if self.markX==nil then return true end
		    	display.getCurrentStage():setFocus( nil )
		    	local loc = getLocation1(self.x)
		    	local oldLoc = self.wf_place
		    	--self.wf_place = loc
		    	--native.showAlert("alert","new location is "..loc.." old loc is "..oldLoc)
		    	moveTile(self,oldLoc,loc)
		    -- put the letter where it goes in the new order
		    elseif event.phase == "cancelled" then
		    	--put the object back where it started
		    	self.x,self.y = self.origX,self.origY
		    	display.getCurrentStage():setFocus( nil )
		    end
		    
		    return true
		end

		function displayGroup:tap(event)
			--local tile = self
			if self.wf_locked ==nil or self.wf_locked == false then
				self.wf_locked = true
				local mask = graphics.newMask( "graphics/redmask.png")
				self:setMask(mask)
			else
				self.wf_locked = false
				self:setMask(nil)
				--tile:setFillColor(0,0,0,0)
			end

		end

		displayGroup:addEventListener("touch",displayGroup)
		displayGroup:addEventListener("tap",displayGroup)
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

--sort the tiles in a random order
local function randomSort1()
	--get random numbers
	local lockedTiles = nil
	local regularTiles = nil
	local finalList = nil
	local max = numLetters
	local newPlace = math.random(max)
	local i = numLetters
	--print("in random sort i ="..i)
	--make a list of the locked tiles and a list of regular tiles
	while i>=1 do
		
		if listOfLetters[i].wf_locked then
			lockedTiles = {tile = listOfLetters[i], next=lockedTiles}
		else
			regularTiles = {tile = listOfLetters[i], next=regularTiles}
		--	print("regular i="..i)
		end
		i=i-1
	end
	--print("befor random")
	printList(lockedTiles)
	printList(regularTiles)
	printList(regularTiles)
	-- randomly insert the tiles
	if(regularTiles~=nil) then
		--print("regularTiles is not nil "..regularTiles.tile.wf_letter)
		finalList = {tile = regularTiles.tile,next=nil}
		local currentTile= regularTiles.next
		local count = 1
		while currentTile~=nil and count <= numLetters do
			finalList = insertTile(currentTile.tile,finalList,math.random(count+1))
			count = count + 1
			currentTile = currentTile.next
			printList(finalList)
		end
	end
	--insert lockedTiles
	while lockedTiles~= nil do
		finalList = insertTile(lockedTiles.tile,finalList,lockedTiles.tile.wf_place)
		lockedTiles = lockedTiles.next
	end
	--listOfLetters = letterTable
	linkedListToArray(finalList)
	recreateWord()
	if autoCheck then
		checkTilesForWords()
	end
end


--sort the tiles in a random order
local function randomSort()
	--get random numbers
	local letterTable = {}
	local usedLetters = {}
	local max = numLetters
	local newPlace = math.random(max)
	--check for locked letters and copy them over
	for i=1,max do
		if listOfLetters[i].wf_locked~=nil and listOfLetters[i].wf_locked then
			newPlace = i
			--mark the random number used
			usedLetters[newPlace]=true
			letterTable[newPlace] = listOfLetters[i]
			letterTable[newPlace].wf_place = newPlace
			letterTable[newPlace].x = tileStartTable[newPlace]	
		else
			usedLetters[i]=false
		end
		
	end
	--randomize the rest of the letters
	for i=1, max do
		--get a random number that hasn't been used
		--TODO: fix this code
		print("i is "..i)
		if not letterTable[i].wf_locked then
			newPlace = math.random(max)
			local count = 1
			if usedLetters[newPlace] then
				while usedLetters[newPlace] and count < 20 do
					newPlace = math.random(max)
					count = count+1
					--print("random is "..newPlace)
				end
				
			end
			--mark the random number used
			usedLetters[newPlace]=true
			letterTable[newPlace] = listOfLetters[i]
			letterTable[newPlace].wf_place = newPlace
			letterTable[newPlace].x = tileStartTable[newPlace]	
		end
	
	end
	listOfLetters = letterTable
	recreateWord()
	if autoCheck then
		checkTilesForWords()
	end
end



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
	
	local randomButton = display.newRect(displayGroup,rec.contentWidth,0,50,50)
	randomButton:setFillColor(0,0,.3)
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
	-- make the reset button
	local resetButton = display.newText( sceneGroup, "Reset", display.contentCenterX, display.contentCenterY, native.systemFont, fontSize2 )
	resetButton:setFillColor( 1, 1, 1 )
	resetButton.anchorX=0
	resetButton.x = display.actualContentWidth - 120
	resetButton.y = 10 + fontSize2
	local function getNewTiles()
		composer.gotoScene( "scenegetpicture" )
	end
	resetButton:addEventListener("tap",getNewTiles)
	randomButton:addEventListener("tap",randomSort1)
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
	sceneGroup:removeSelf()
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
