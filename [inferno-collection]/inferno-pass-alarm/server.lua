-- Inferno Collection Pass Alarm Version 1.32 Beta
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

-- Master Pass Alarm storage variable
local PassAlarms = {}

RegisterServerEvent("Pass-Alarm:Server")
AddEventHandler("Pass-Alarm:Server", function(Bool, Remove, Request)
	if Bool then
		if Remove then
			if PassAlarms[source] then
				PassAlarms[source] = nil
			end
		end
	else
		if not PassAlarms[source] then
			PassAlarms[source] = true
		end
	end

	TriggerClientEvent("Pass-Alarm:Bounce:ServerValues", -1, PassAlarms)
	TriggerClientEvent("Pass-Alarm:Bounce:NUI", -1, Request, source)
end)