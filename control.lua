require("guiManager")



local surfaceNames={}
local surfaceToItemNames={}
local landfillValue=0
local itemToTileValue=0




local function hasValue (tab, val)
  for index, value in ipairs(tab) do
      if value == val then
          return true
      end
  end

  return false
end

function checkTile(xPos,yPos,tileName,player,surfaceName)
  if (surfaceName == tileName) then
    return false --same surface as placed
  end

  if (surfaceName == "water" or surfaceName == "deepwater")  and (not isLandfillTile or landfillValue==0) then
    return false --tile is water and not using landfill or not enough landfill
  end

  if ((hasValue(surfaceNames,surfaceName) and surfaceName~=tileName)  and isReplaceTile==false) then
    return false --no repleacing
  end

  
  if (itemToTileValue==0) then
    return false --not enough items
  end

  --return items that was scraped

  return true


end




function updateInventory(player)
  local inventory = player.get_main_inventory()
  landfillValue=inventory.get_item_count("landfill")
  itemToTileValue=inventory.get_item_count(itemTileName)
end

function updateInventoryAfterPlace(player,arrayOfItems)
  local inventory = player.get_main_inventory()
  landfillToRemove=math.abs(landfillValue-inventory.get_item_count("landfill"))
  if landfillToRemove>0 then
  inventory.remove({name="landfill",count=landfillToRemove})
  end
  itemToTileRemove=math.abs(itemToTileValue-inventory.get_item_count(itemTileName))
  if itemToTileRemove>0 then
    inventory.remove({name=itemTileName,count=itemToTileRemove})
  end

  for key, value in pairs(arrayOfItems) do

    
    if inventory ~= nil then
        inventory.insert({name=key, count=value})
    end
  end
  arrayOfItems={}
end


function addItemToReturn(arrayOfItems,tileName,player)
  if (arrayOfItems[surfaceToItemNames[tileName]] == nil) then
    arrayOfItems[surfaceToItemNames[tileName]]=1
  else
    arrayOfItems[surfaceToItemNames[tileName]]=arrayOfItems[surfaceToItemNames[tileName]]+1
  end
end

function addTile(xPos,yPos,tileName,player,arrayOfTiles,arrayOfItems)

  local surfaceName=player.surface.get_tile(xPos,yPos).name
  if checkTile(xPos,yPos,tileName,player,surfaceName) then
    table.insert(arrayOfTiles,{name=tileName, position={xPos,yPos}})
    if (player.surface.get_tile(xPos,yPos).name == "water" or player.surface.get_tile(xPos,yPos).name == "deepwater") then
      landfillValue=landfillValue-1
    end
    itemToTileValue=itemToTileValue-1
    if (hasValue(surfaceNames,surfaceName)) then
      addItemToReturn(arrayOfItems,surfaceName,player)
    end
  end

end

function insertSquareTile(xPos,yPos,player,arrayOfTiles,arrayOfItems)
  for x=-placeSize,placeSize do
    for y=-placeSize,placeSize do
      addTile(xPos+x,yPos+y,tileName,player,arrayOfTiles,arrayOfItems)
    end
  end

end

script.on_event(defines.events.on_player_changed_position,
  function(event)
    local player = game.get_player(event.player_index) 
  
    if  isPlaceTile then
      local arrayOfTiles = {}
      local xPos=player.position.x
      local yPos=player.position.y
      local arrayOfItems={}
      updateInventory(player)
      insertSquareTile(xPos,yPos,player,arrayOfTiles,arrayOfItems)
      player.surface.set_tiles(arrayOfTiles)
      updateInventoryAfterPlace(player,arrayOfItems)
    end
    
  end
)

function getCreatedSurfaceFromItemName(itemName)

  if game.item_prototypes[itemName].place_as_tile_result.result.name ~=nil  then
    return game.item_prototypes[itemName].place_as_tile_result.result.name --different name from item and tile
  else
    return itemName --same name for item and tile
  end
end


function init(playerIndex)
  buildGui(playerIndex)

  local tileNames=game.get_filtered_item_prototypes({{filter="place-as-tile"} ,{filter="name", name="landfill",mode="and", invert=true}})
  for _, p in pairs(tileNames) do 
    table.insert(surfaceNames,getCreatedSurfaceFromItemName(p.name))
    surfaceToItemNames[getCreatedSurfaceFromItemName(p.name)]=p.name
  end
end

script.on_event(defines.events.on_cutscene_cancelled,
  function(event)
    
    init(game.get_player(event.player_index))
 
  end
)

script.on_event(defines.events.on_player_created,
  function(event)
    init(game.get_player(event.player_index))
  end
)


script.on_init(function()

  for _, playerIndex in pairs(game.players) do
    init(playerIndex)
  end
end)


script.on_configuration_changed(function()

  for _, playerIndex in pairs(game.players) do
    replaceGui(playerIndex)
  end
end)






