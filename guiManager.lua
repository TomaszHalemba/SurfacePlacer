
local isGuiExist=false
local isVisible=false
local tileName="concrete"
local itemTileName="concrete"
local isPlaceTile=false
local isReplaceTile=false
local isLandfillTile=false
local placeSize=2

function replaceGui(player)
local cGui = player.gui.left
if cGui["PlaceTileModMainButton"] then
    cGui["PlaceTileModMainButton"].destroy()
end

if cGui["PlaceTileModFrame"] then
    cGui["PlaceTileModFrame"].destroy()
end


isGuiExist=false

buildGui(player)
end


function buildGui(player)

    if not isGuiExist then
        local cGui = player.gui.left
        local button = cGui.add{
            type = "button",
            name = "PlaceTileModMainButton",
            direction = "vertical",
            caption={"gui.mainButtonName"," "}

        }
        local frame=cGui.add{
        type = "frame",
        name = "PlaceTileModFrame",
        direction = "vertical",
        }
        frame.add{
            type = "label",
            direction = "horizontal",
            caption = {"gui.chooseTile"," "},
        }
        frame.add{
            type = "choose-elem-button",
            name = "PlaceTileModChooseTile",
            direction = "vertical",
            elem_type="item",
            elem_value="concrete",
            elem_filters={{filter="place-as-tile"} ,{filter="name", name="landfill",mode="and", invert=true}},
        }

        local textfieldFrame= frame.add{
          name = "PlaceTileModTextFieldPlaceSizeFrame",
          type = "flow",
          direction = "horizontal"
      }
      textfieldFrame.add{
        type = "label",
        direction = "horizontal",
        caption = {"gui.sizeLabel"," "},
    }

        local textfield=textfieldFrame.add{
            type = "textfield",
            name = "PlaceTileModTextFieldPlaceSize",
            text = "2",
            
            numeric=true,
            allow_negative=false
        }
        textfield.style.minimal_width = 30
        textfield.style.maximal_width = 100

        

        local placeTileCheckBoxFrame = frame.add{
            name = "PlaceTileModCheckBoxFrame",
            type = "flow",
            direction = "horizontal"
        }
        placeTileCheckBoxFrame.add{
            type = "checkbox",
            name = "PlaceTileModToLay",
            direction = "horizontal",
            state=false
        }
        placeTileCheckBoxFrame.add{
            type = "label",
            direction = "horizontal",
            caption =  {"gui.placeTiles"," "},
        }
    
    
    
        local placeLandFillCheckBoxFrame = frame.add{
            name = "PlaceLandFillModCheckBoxFrame",
            type = "flow",
            direction = "horizontal"
        }
        placeLandFillCheckBoxFrame.add{
            type = "checkbox",
            name = "PlaceLandFillModToLay",
            direction = "horizontal",
            state=false
        }
        placeLandFillCheckBoxFrame.add{
            type = "label",
            direction = "horizontal",
            caption = {"gui.useLandfill"," "},
        }
    
    
        local replaceCheckBoxFrame = frame.add{
            name = "replaceModCheckBoxFrame",
            type = "flow",
            direction = "horizontal"
        }
        replaceCheckBoxFrame.add{
            type = "checkbox",
            name = "replaceModToLay",
            direction = "horizontal",
            state=false
        }
        replaceCheckBoxFrame.add{
            type = "label",
            direction = "horizontal",
            caption = {"gui.replaceTiles"," "},
        }
    
        frame.visible=isVisible
        isGuiExist=true
    end
  
  end



  
script.on_event(defines.events.on_gui_click, 
function(event)
  local player = game.get_player(event.player_index)
  if event.element.name=="PlaceTileModMainButton" then
    
    isVisible= not isVisible
    player.gui.left["PlaceTileModFrame"].visible= isVisible
  end

end
)



script.on_event(defines.events.on_gui_checked_state_changed, 
function(event)
  local player = game.get_player(event.player_index)
  if event.element.name=="PlaceTileModToLay" then
    isPlaceTile=event.element.state
  end

  if event.element.name=="replaceModToLay" then
    isReplaceTile=event.element.state
  end

  if event.element.name=="PlaceLandFillModToLay" then
    isLandfillTile=event.element.state
  end



end
)


script.on_event(defines.events.on_gui_confirmed, 
function(event)
  local player = game.get_player(event.player_index)
  if event.element.name=="PlaceTileModTextFieldPlaceSize" then
    placeSize=tonumber(event.element.text)
  end

end
)



script.on_event(defines.events.on_gui_elem_changed, 
function(event)
  local player = game.get_player(event.player_index)
  if event.element.name=="PlaceTileModChooseTile" then

    tileName=getCreatedSurfaceFromItemName(event.element.elem_value)
    itemTileName=event.element.elem_value

  end
end
)


