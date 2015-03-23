if SERVER then
   AddCSLuaFile( "shared.lua" )
end

if CLIENT then
   SWEP.PrintName = "Jihad Bomb"
   SWEP.Slot = 8
   SWEP.Icon = "vgui/ttt/icon_jihad"
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

-- Standard GMod values
SWEP.HoldType = "slam"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

-- Model settings
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/v_jb.mdl"
SWEP.WorldModel = "models/weapons/w_jb.mdl"

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_ROLE

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { nil }

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = { ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
--SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- Equipment menu information is only needed on the client
if CLIENT then
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Sacrifice yourself to Allah.\n\nYour 72 virgins await."
   };
end

-- Reload does nothing
function SWEP:Reload()
   return false
end

-- Precache sounds
function SWEP:Initialize()
   util.PrecacheSound( "weapons/jihad/jihad.wav" )
   util.PrecacheSound( "weapons/jihad/big_explosion.wav" )
end

-- Particle effects / Begin attack
function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire(CurTime() + 2)

   local effectdata = EffectData()
   effectdata:SetOrigin( self.Owner:GetPos() )
   effectdata:SetNormal( self.Owner:GetPos() )
   effectdata:SetMagnitude( 8 )
   effectdata:SetScale( 1 )
   effectdata:SetRadius( 20 )
   util.Effect( "Sparks", effectdata )
   self.BaseClass.ShootEffects( self )

   -- The rest is only done on the server
   if (SERVER) then
      timer.Simple(2, function() self:Asplode() end )
      self.Owner:EmitSound( "weapons/jihad/jihad.wav" )
   end
end

-- Explosion properties
function SWEP:Asplode()
   local k, v

   local ent = ents.Create( "env_explosion" )
   ent:SetPos( self.Owner:GetPos() )
   ent:SetOwner( self.Owner )
   ent:SetKeyValue( "iMagnitude", "250" )
   ent:Spawn()
   ent:Fire( "Explode", 0, 0 )
   ent:EmitSound( "weapons/jihad/big_explosion.wav", 500, 500 )
   self:Remove()
   
   self.Owner:Kill( )
end