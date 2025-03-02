script_name("Autoupdate Script")
script_author("FORMYS")
script_description("Автообновление скрипта")

require "lib.moonloader"
local inicfg = require "inicfg"
local keys = require "vkeys"
local imgui = require "imgui"
local encoding = require "encoding"
local distatus = require "moonloader".download_status

encoding.default = "CP1251"
u8 = encoding.UTF8

local update_state = false
local script_vers = 3  -- Текущая версия скрипта
local script_vers_text = "2"  -- Версия, которую нужно обновить
local update_url = "https://raw.githubusercontent.com/Harcye/test/main/update.ini"  -- URL для файла с информацией о версии
local update_path = getWorkingDirectory() .. "/update.ini"
local script_url = "https://raw.githubusercontent.com/Harcye/test/main/autoupdate.lua"  -- URL для скачивания новой версии скрипта
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("autoupdate", cmd_update)
    check_for_update()
end

-- Проверка наличия обновлений
function check_for_update()
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            local update_ini = inicfg.load(nil, update_path)
            if tonumber(update_ini.info.vers) > script_vers then
                sampAddChatMessage("Доступно обновление: " .. update_ini.info.vers, -1)
                update_state = true
            end
            os.remove(update_path)
            if update_state then download_script() end
        else
            sampAddChatMessage("Не удалось загрузить информацию об обновлениях.", -1)
        end
    end)
end

-- Скачивание новой версии скрипта
function download_script()
    downloadUrlToFile(script_url, script_path, function(id, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            sampAddChatMessage("Скрипт успешно обновлен до версии 2!", -1)
            thisScript():reload()  -- Перезагружаем скрипт для применения обновлений
        else
            sampAddChatMessage("Ошибка при обновлении скрипта.", -1)
        end
    end)
end

-- Команда для активации автообновления
function cmd_update()
    sampShowDialog(1000, "Автообновление 2.0", "{FFFFFF} Это урок по обновлению\n{FFFF00} Новая версия доступна\n\n{FFFFFF} Создано Алекс Чай", "Закрыть", "", 0)
end
