include('shared.lua')

SWEP.PrintName = "Mine Turtle"
SWEP.Slot = 4

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:OnRemove()
	if (IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive()) then
		RunConsoleCommand("lastinv")
	end
end

function SWEP:DrawHUD()
	local x = ScrW() / 2.0
	local y = ScrH() * 0.995

	draw.SimpleText("Primary attack to drop.", "Default", x, y - 20, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText("Secondary attack to stick to a wall.", "Default", x, y, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end