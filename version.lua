--[[ Version Checker ]]--
local VERSION = "2.0.6"

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        checkVersion()
    end
end)

function checkVersion()
  PerformHttpRequest("https://raw.githubusercontent.com/TanguyOrtegat/esx_jb_eden_garage2/master/version.json", function(err, text, h)
    if err == 200 then
      local versionArray = json.decode(text)
      local gitVersion = versionArray.version

      if(VERSION ~= gitVersion) then
        print("\n=================================\n")
        local patchnoteArray = versionArray.patchnote
        local patchnote = ""
        for _, line in pairs(patchnoteArray) do
          patchnote = patchnote..line.."\n"
        end

        print("A new version of esx_eden_garage2 is available: "..gitVersion)
        print("patchnote: \n"..patchnote)
        print("\n=================================\n")
      end
    else
      print("can't get version")
    end
  end, "GET")
end
