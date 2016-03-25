include('shared.lua')

SWEP.PrintName = "M4 SLAM"
SWEP.Slot = 6
SWEP.Icon = "vgui/ttt/icon_slam"

-- Equipment menu information is only needed on the client
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "A Mine which can be manually detonated\nor sticked on a wall as a tripmine.\n\nNOTE: Can be shot and destroyed by everyone."
}

local x = ScrW() / 2.0
local y = ScrH() * 0.995
function SWEP:DrawHUD()
	draw.SimpleText("Primary attack to deploy.", "Default", x, y - 20, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("Secondary attack to detonate.", "Default", x, y, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

	return self.BaseClass.DrawHUD(self)
end

function SWEP:OnRemove()
	if (IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive()) then
		RunConsoleCommand("lastinv")
	end
end
