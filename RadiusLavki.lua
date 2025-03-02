local active = false
local font = renderCreateFont('Verdana', 8, 5)
local vk = require 'vkeys'
local repo_url = "https://raw.githubusercontent.com/Harcye/univeri-/main/tema08.lua"
local script_path = thisScript().path

function download_update()
    lua_thread.create(function()
        local temp_path = getGameDirectory() .. "\\moonloader\\temp_script.lua"
        downloadUrlToFile(repo_url, temp_path, function(_, status)
            if status == 200 then
                os.remove(script_path)
                os.rename(temp_path, script_path)
                sampAddChatMessage("Ñêğèïò îáíîâë¸í! Ïåğåçàãğóçèòå åãî êîìàíäîé /rlv", 0x54e83a)
            else
                sampAddChatMessage("Îøèáêà îáíîâëåíèÿ: " .. status, 0xFF0000)
            end
        end)
    end)
end

function check_for_update()
    sampAddChatMessage("Ïğîâåğêà îáíîâëåíèé...", 0x54e83a)
    download_update()
end

main = function()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('rlv', function() 
        active = not active 
        if active then
            sampAddChatMessage("Ğåæèì ëàâêè àêòèâèğîâàí!", 0x54e83a)
        else
            sampAddChatMessage("Ğåæèì ëàâêè äåàêòèâèğîâàí!", 0xFF0000)
        end
    end)
    sampRegisterChatCommand('update', check_for_update)

    check_for_update() -- àâòîîáíîâëåíèå ïğè çàïóñêå

    while true do wait(0)
        if active then
            renderFontDrawText(font, 'rlavka work!', 10, 400, 0xff54e83a)
            for IDTEXT = 0, 2048 do
                if sampIs3dTextDefined(IDTEXT) then
                    local text, color, posX, posY, posZ = sampGet3dTextInfoById(IDTEXT)
                    if text == "Óïğàâëåíèÿ òîâàğàìè." and not isCentralMarket(posX, posY) then
                        local myPos = {getCharCoordinates(1)}
                        drawCircleIn3d(posX, posY, posZ - 1.3, 5, 36, 1.5, getDistanceBetweenCoords3d(posX, posY, 0, myPos[1], myPos[2], 0) > 5 and 0xFFFFFFFF or 0xFFFF0000)
                        renderFontDrawText(font, '\n\n×òîáû âûñòàâèòü ëàâêó íàæìèòå: {b95ae8}Q', 10, 400, 0xff54e83a)
                        if wasKeyPressed(vk.VK_Q) and not sampIsCursorActive() then
                            sampSendChat('/lavka')
                        end
                    end
                end
            end
        end
    end
end

drawCircleIn3d = function(x, y, z, radius, polygons, width, color)
    local step = math.floor(360 / (polygons or 36))
    local sX_old, sY_old
    for angle = 0, 360, step do
        local lX = radius * math.cos(math.rad(angle)) + x
        local lY = radius * math.sin(math.rad(angle)) + y
        local lZ = z
        local _, sX, sY, sZ = convert3DCoordsToScreenEx(lX, lY, lZ)
        if sZ > 1 then
            if sX_old and sY_old then
                renderDrawLine(sX, sY, sX_old, sY_old, width, color)
            end
            sX_old, sY_old = sX, sY
        end
    end
end

isCentralMarket = function(x, y)
    return (x > 1044 and x < 1197 and y > -1565 and y < -1403)
end
