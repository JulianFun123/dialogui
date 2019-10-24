local web = CreateWebUI(0, 0, 0, 0, 1, 16)
SetWebAlignment(web, 0, 0)
SetWebAnchors(web, 0, 0, 1, 1)
SetWebURL(web, "http://asset/dialogui/dialog.html")
local nextId = 1
local dialogs = {}
local lastOpened = -1
function createDialog(title, text, ...)
    local id = nextId
    nextId = nextId + 1
    dialogs[id] = {
        title = title,
        text = text,
        buttons = {...},
        inputs = {}
    }
    return id
end
function addDialogSelect(dialog, label, ...)
    table.insert(dialogs[dialog]["inputs"], {
        type = "select",
        name = label,
        options = {...}
    })
end
function addDialogTextInput(dialog, label)
    table.insert(dialogs[dialog]["inputs"], {
        type = "text",
        name = label
    })
end
function destroyDialog(dialog)
    dialogs[dialog] = nil
    if lastOpened == dialog then
        CloseDialog()
    end
end
function closeDialog()
    lastOpened = -1
    ExecuteWebJS(web, "CloseDialog();");
    SetIgnoreLookInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
end
function showDialog(dialog)
    if dialogs[dialog] == nil then
        return
    end
    lastOpened = dialog
    local d = dialogs[dialog]
    local json = ""
    if d.title ~= nil then
        json = "title:\""..d.title.."\","
    end
    if d.text ~= nil then
        json = json.."text:\""..d.text.."\","
    end
    if d.inputs ~= nil then
        json = json.."inputs:["
        for i=1,#d.inputs do
            if i > 1 then
                json = json..","
            end
            json = json.."{type:\""..d.inputs[i].type.."\",name:\""..d.inputs[i].name.."\""
            if d.inputs[i].options ~= nil then
                json = json..",options:["
                for j=1,#d.inputs[i].options do
                    if j > 1 then
                        json = json..","
                    end
                    json = json.."\""..d.inputs[i].options[j].."\""
                end
                json = json.."]"
            end
            json = json.."}"
        end
        json = json.."],"
    end
    json = json.."buttons:["
    for i=1,#d.buttons do
        if i > 1 then
            json = json..","
        end
        json = json.."\""..d.buttons[i].."\""
    end
    ExecuteWebJS(web, "SetDialog("..dialog..",{"..json.."]});")
    SetIgnoreLookInput(true)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
end
AddEvent("__dialog_system_closed", function()
    lastOpened = -1
    SetIgnoreLookInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
end)
AddFunctionExport("create", createDialog)
AddFunctionExport("addSelect", addDialogSelect)
AddFunctionExport("addTextInput", addDialogTextInput)
AddFunctionExport("show", showDialog)
AddFunctionExport("close", closeDialog)
AddFunctionExport("destroy", destroyDialog)