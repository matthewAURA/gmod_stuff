include('shared.lua')

SWEP.PrintName = "Mine Turtle"
SWEP.Slot = 6
SWEP.Icon = "vgui/ttt/icon_mine_turtle"

-- Equipment menu information is only needed on the client
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "HELLO!\n\nNOTE: Can be shot and destroyed by everyone."
}

local hudtext = {
	{text="Primary fire to drop.", font="TabLarge", xalign=TEXT_ALIGN_RIGHT},
	{text="Secondary fire to stick.", font="TabLarge", xalign=TEXT_ALIGN_RIGHT},
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
