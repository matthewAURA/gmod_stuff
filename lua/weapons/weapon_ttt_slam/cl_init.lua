include('shared.lua')

SWEP.PrintName = "M4 SLAM"
SWEP.Slot = 6
SWEP.Icon = "vgui/ttt/icon_slam"

-- Equipment menu information is only needed on the client
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "A Mine which can be manually detonated\nor sticked on a wall as a tripmine.\n\nNOTE: Can be shot and destroyed by everyone."
}

local hudtext = {
	{text="Primary fire to deploy.", font="TabLarge", xalign=TEXT_ALIGN_RIGHT},
	{text="Secondary fire to detonate.", font="TabLarge", xalign=TEXT_ALIGN_RIGHT},
}

function SWEP:DrawHUD()
	local x = ScrW() - 40
	hudtext[1].pos = {x, ScrH() - 80}
	draw.TextShadow(hudtext[1], 2)
	hudtext[2].pos = {x, ScrH() - 40}
	draw.TextShadow(hudtext[2], 2)
end

function SWEP:OnRemove()
	if (IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive()) then
		RunConsoleCommand("lastinv")
	end
end
