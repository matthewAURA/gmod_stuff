if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("254177306")
end

if CLIENT then
   SWEP.PrintName = "S.L.A.M."
   SWEP.Slot = 7
   SWEP.Icon = "vgui/ttt/icon_slam"
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--- Default GMod values ---
SWEP.HoldType = "slam"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.5
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.FiresUnderwater = false

--- Model settings ---
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 64
SWEP.ViewModel = Model("models/weapons/v_slam.mdl")
SWEP.WorldModel	= Model("models/weapons/w_slam.mdl")

--- TTT config values ---

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP2
   
-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, 
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- Equipment menu information is only needed on the client
if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "A mine, with a red laser, placeable on walls.\n\nWhen the red laser is crossed by innocents or\ndetectives, the mine explodes. Can be shot and\ndestroyed by everyone."
	};
end


function SWEP:Deploy()
	self:SendWeaponAnim(ACT_SLAM_TRIPMINE_DRAW)
	return true
end

function SWEP:OnRemove()
	if (CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive()) then
		RunConsoleCommand("lastinv")
	end
end

function SWEP:PrimaryAttack()
	if (self:CanPrimaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self.Weapon:EmitSound(Sound("Weapon_SLAM.SatchelThrow"))
		
		self:TripMineStick()
	end
end

function SWEP:TripMineStick()
	local ply = self.Owner
	
	if (SERVER and IsValid(ply)) then
		local ignore = {ply, self.Weapon}
		local spos = ply:GetShootPos()
		local epos = spos + ply:GetAimVector() * 80
		
		local tr = util.TraceLine({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID})
		
		if (tr.HitWorld) then
			local mine = ents.Create("npc_tripmine")
			
			if (IsValid(mine)) then
				local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID}, mine)
				
				if (tr_ent.HitWorld) then
					local ang = tr_ent.HitNormal:Angle()
					ang.p = ang.p + 90
					mine:SetPos(tr_ent.HitPos + (tr_ent.HitNormal * 3))
					mine:SetAngles(ang)
					mine:SetOwner(ply)
					mine:Spawn()
					mine.fingerprints = self.fingerprints
					self:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH)
					
					local holdup = self.Owner:GetViewModel():SequenceDuration()
					timer.Simple(holdup, function() self:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH2) end)
					timer.Simple(holdup + .1, function()
										if (self.Weapon:Clip1() == 0 and self.Owner:GetAmmoCount(self.Weapon:GetPrimaryAmmoType()) == 0) then
											self:Remove()
										else
											self:Deploy()
										end
                                end)

					self.Planted = true
					self:TakePrimaryAmmo(1)
				end
			end
		end
	end
end

-- Secondary attack does nothing
function SWEP:SecondaryAttack()
end

-- Reload does nothing
function SWEP:Reload()
end