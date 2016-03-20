include('shared.lua')

SWEP.PrintName = "Mine Turtle"
SWEP.Slot = 6
SWEP.Icon = "vgui/ttt/icon_mine_turtle"

-- Equipment menu information is only needed on the client
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "HELLO!\n\nNOTE: Can be shot and destroyed by everyone."
}

function SWEP:DrawHUD()
	local x = ScrW() / 2.0
	local y = ScrH() * 0.995

	draw.SimpleText("Primary attack to drop.", "Default", x, y - 20, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("Secondary attack to stick to a wall.", "Default", x, y, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

	return self.BaseClass.DrawHUD(self)
end

function SWEP:OnRemove()
	if (IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive()) then
		RunConsoleCommand("lastinv")
	end
end
