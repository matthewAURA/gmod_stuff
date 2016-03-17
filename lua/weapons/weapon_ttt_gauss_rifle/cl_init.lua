include('shared.lua')

SWEP.PrintName = "Gauss Rifle"
SWEP.Slot = 6
SWEP.Icon = "vgui/ttt/icon_gauss_rifle"

-- Equipment menu information is only needed on the client
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "Fires heavy explosives."
}

-- Draw the scope on the HUD
local scope = surface.GetTextureID("sprites/scope")
function SWEP:DrawHUD()
	if self:GetIronsights() then
		surface.SetDrawColor(0, 0, 0, 255)

		local x = ScrW() / 2.0
		local y = ScrH() / 2.0
		local scope_size = ScrH()

		-- crosshair
		local gap = 80
		local length = scope_size
		surface.DrawLine(x - length, y, x - gap, y)
		surface.DrawLine(x + length, y, x + gap, y)
		surface.DrawLine(x, y - length, x, y - gap)
		surface.DrawLine(x, y + length, x, y + gap)

		gap = 0
		length = 50
		surface.DrawLine(x - length, y, x - gap, y)
		surface.DrawLine(x + length, y, x + gap, y)
		surface.DrawLine(x, y - length, x, y - gap)
		surface.DrawLine(x, y + length, x, y + gap)

		-- cover edges
		local sh = scope_size / 2
		local w = (x - sh) + 2
		surface.DrawRect(0, 0, w, scope_size)
		surface.DrawRect(x + sh - 2, 0, w, scope_size)
		surface.SetDrawColor(255, 0, 0, 255)
		surface.DrawLine(x, y, x + 1, y + 1)

		-- scope
		surface.SetTexture(scope)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
	else
		return self.BaseClass.DrawHUD(self)
	end
end

function SWEP:AdjustMouseSensitivity()
	return (self:GetIronsights() and 0.2) or nil
end
