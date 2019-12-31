/*===============================================================================================================
				  [Dragon Ball Mode]
				
				** Description of Mod: 
	      Each character has a power and has a different Transformation and which 
			has a similar power as Super Buu and Broly.
			
	\----------------------------------------------------------------------------------------/
			
			** Description of Characters (Heroes): 
		* Goku : 

			- Transformations and Attacks :
			Super Saiajin : Unleash a Simple Ki - Blast
			Super Saiajin 2 : Unleash an Simple Blue Kamehameha
			Super Saiajin 3 : Unleash an Dragon First
			Super Saiajin 4 : Unleash an Enhanced 10x Kamehameha
			Super Saiajin 5 : Unleash a Spirit Bomb
		
		* Vegeta :
		
			- Transformations and Attacks :
			Super Saiajin : Unleash a Simple Ki - Blast
			Super Saiajin 2 : Unleash an Garlic Gun
			Super Saiajin Blue : Unleash a Final Flash
			Super Saiajin 4 : Unleash a Final Shine Attack
		
		* Gohan : 
		
			- Transformations and Attacks :
			Attack 1 : Simple Unleash Ki - Blast 
			Super Saiajin : Unleash an Masenko
			Super Saiajin 2 : Unleash an Kamehameha
		
		* Krilin :
		
			- Attacks :
			Attack 1 : Unleash a Simple Ki - Blast
			Attack 2 : Unleash an Kamehameha
			Attack 3 : Unleash an Destruction Disc
		
		* Picolo :

			- Attacks :
			Attack 1 : Unleash a Simple Ki - Blast
			Attack 2 : Unleash an Masenko
			Attack 3 : Unleash a Special Beam Cannon
			
	\----------------------------------------------------------------------------------------/
			
			** Description of Character (Villains): 
			
		* Frieza :

			- Transformations and Attacks :
			1st Transformation : Unleash a Simple Ki - Blast
			Transformation 2 : Unleash a Death Beam
			Final Form : Unleash an Destruction Disc (Similar Krilin the only purple)
			100 % Power : Unleash a Death Ball
		
		* Cell:
		
			- Transformations and Attacks :
			Semi - Perfect Form : Unleash a Simple Ki - Blast
			Perfect Form : Unleash a Death Beam
			Super Perfect Form : Unleash a Green Kamehameha
		
		* Super Buu & Broly :
		
			- Attacks :
			Attack 1 : Unleash an Galitgun
			Attack 2 : Unleash a Final Flash
			Attack 3 : Unleash a Big Bang
			Attack 4 : Unleash a Death Ball
		
		* Omega Sheron (Or Li - Shen - Long) :
		
			- Transformations and Attacks :
			3 Dragon Balls Absorbed : Unleash a Simple Ki - Blast
			5 Dragon Balls Absorbed : Unleash an Dragon Thunder 
			All Dragon Balls Absorbed : Unleash an Minus Energy Power Ball
			
	\----------------------------------------------------------------------------------------/			
				  ** Credits:

		- Version Created By: [P]erfec[T] [S]cr[@]s[H]
		- Thanks Vittu For Goku Hero´s Code
		- Thanks green name for some sprites and sounds
		
	\----------------------------------------------------------------------------------------/
		
				** Change Log:
		v 1.0:
			* First Relase
				
		v 1.1: 
			* Fixed Some Bugs
			* Optimized Code
			* Added .cfg File

		v 1.2:
			* Fixed Health's Engine Bug
			* Fixed Bug of Reable Channel Overflow with powerup effect
			* Optimized Code

		v 1.3: (BIG UPDATE)
			* Added Player Models
			* Added Sounds of Attacks/Tranformations for all characters (Execpt Omega Shenron)
			* Added Knife Sound
			* Fixed Some Bugs
			* Etc.
		v 1.4:
			* Fixed Sounds
			* Use button in FM_emitsound
			* Fixed Some bugs
			* Added Join Spec Option
			* Added More Superbuu Models
 
		v 1.5:
			* Cached Itens for reduce lag/delay (Thanks addons_zz)
			* No Amx 1.8.2 Suport now (Now requires AMX 1.8.3 or higher)
			* Removed set_user_model plugin needed (Because of cstrike module fixes on AMX 1.8.3)
			* Optimed Code
			* Removed Redudant Resources
			* DBZ tag changed to DBM 
			* Added Omega Shenron Sounds
			* Added Frieza's Golden Form
      * Changed Vegeta Super Saiyan 3 to Vegeta Super Saiyan Blue
			* Power up description updated on lang (Lang Updated)
	
======================================================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <fun>

#define PLAYER_MODELS // Enable Player Models
#define POWER_CLASSNAME "dbm_power_ent"

// CS Player PData Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_CSMENUCODE = 205

// Linux diff's
const OFFSET_LINUX = 5 // offsets 5 higher in Linux builds

#if defined PLAYER_MODELS
#define TASK_MODEL 31219283
#endif

#define PLUGIN "Dragon Ball Mod [Heroes vs Villains]"
#define VERSION "1.5"
#define AUTHOR "[P]erfec[T] [S]cr[@]s[H]"

#define is_user_valid_connected(%1) (1 <= %1 <= g_maxpl && g_is_user_connected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxpl && g_is_user_alive[%1])
#define TASK_LOOP_BOTS 5139812935
#define TASK_LOOP_PLAYERS 2139812931
#define DBZ_KNIFE_V_MODEL "models/db_mod_15/v_knife_dbm.mdl" // Knife Model

new g_bots_count, g_players_count, g_current_index, g_bot_round_timer[33]
new g_bots_connected[32], g_bots_power_allow[33], g_players_connected[32], bool:g_is_user_alive[33], bool:g_is_user_connected[33]

new const HeroLangs[][] = { "NONE", "CHARACTER_GOKU", "CHARACTER_VEGETA", "CHARACTER_GOHAN", "CHARACTER_KRILLIN", "CHARACTER_PICCOLO"};
new const VillainLangs[][] = { "NONE", "CHARACTER_FRIEZA", "CHARACTER_CELL", "CHARACTER_BUU", "CHARACTER_BROLY", "CHARACTER_OMEGA"};

// General variables
new g_villain_id[33], g_hero_id[33], cvar_energy_for_second, cvar_energy_need, cvar_start_life_quantity, cvar_blast_decalls, cvar_powerup_effect
new g_power[4][33], g_max[2][33], g_energy_level[6], fw_gSpawn, spr[2], g_msg_syc, g_maxpl

// Characters Cvars
new cvar_goku[10], cvar_frieza[8], cvar_vegeta[8], cvar_gohan[6], cvar_krilin[6], cvar_picolo[6], cvar_broly[8], cvar_superbuu[8], cvar_cell[6], cvar_omega_sheron[6]

static const g_burnDecal[3] = {28, 29, 30}
static const g_burnDecalBig[3] = {46, 47, 48}

new const Remove_Entities[][] = { "func_bomb_target", "info_bomb_target", "hostage_entity", "monster_scientist", "func_hostage_rescue", "info_hostage_rescue",
"info_vip_start", "func_vip_safetyzone", "func_escapezone"}

#define MAX_TRAILS 3
new g_trail[MAX_TRAILS]
new const Trail_Sprs[MAX_TRAILS][] = { "sprites/db_mod_15/dbm_trail.spr", "sprites/db_mod_15/dbm_trail_shock.spr", "sprites/muzzleflash2.spr"}

#define MAX_EXPLOSION 5
new g_explosion[MAX_EXPLOSION]
new const Exp_Sprs[MAX_EXPLOSION][] = { "sprites/db_mod_15/exp_yellow.spr", "sprites/db_mod_15/exp_blue.spr", "sprites/db_mod_15/exp_red.spr", "sprites/db_mod_15/exp_purple.spr", "sprites/db_mod_15/exp_green.spr" }

#define MAX_POWER_MODELS 17
new const Power_Models[MAX_POWER_MODELS][] = {
	"sprites/db_mod_15/dbm_yellow_beam.spr",
	"sprites/db_mod_15/dbm_blue_beam.spr",
	"sprites/db_mod_15/dbm_red_beam.spr",
	"sprites/db_mod_15/dbm_green_beam.spr",
	"sprites/db_mod_15/spirit_bomb.spr",
	"sprites/db_mod_15/dragon_first.spr",
	"sprites/db_mod_15/dbm_purple_beam.spr",
	"sprites/db_mod_15/frieza_deathball.spr",
	"sprites/db_mod_15/final_flash_charge.spr",
	"sprites/db_mod_15/broly_big_bang.spr",
	"sprites/db_mod_15/broly_death_ball.spr",
	"sprites/db_mod_15/buu_final_flash_charge.spr",
	"sprites/db_mod_15/buu_big_bang.spr",
	"sprites/db_mod_15/buu_death_ball.spr",
	"sprites/db_mod_15/omega_mepb.spr",
	"sprites/nhth1.spr",
	"models/db_mod_15/dbm_dest_disc.mdl"
}

new const knife_sounds[][] = { "db_mod_15/knife_hit.wav", "db_mod_15/knife_hitstab.wav", "db_mod_15/knife_miss1.wav", "db_mod_15/knife_miss2.wav", "db_mod_15/knife_miss3.wav" }

#if defined PLAYER_MODELS
// Hero Player Models
new goku_models[][] = { "dbz_goku", "dbz_goku2", "dbz_goku2", "dbz_goku3", "dbz_goku4", "dbz_goku5" }
new vegeta_models[][] = { "dbz_vegeta", "dbz_vegeta2", "dbz_vegeta2", /*"dbz_vegeta3",*/ "dbs_vegeta_blue", "dbz_vegeta4" }
new gohan_models[][] = { "dbz_gohan", "dbz_gohan", "dbz_gohan_ssj", "dbz_gohan_ssj2" }
#define KRILLIN_MODEL "dbz_krillin"
#define PICCOLO_MODEL "dbz_piccolo"

// Villain Player Models
new frieza_models[][] = { "dbz_frieza", "dbz_frieza2", "dbz_frieza3", "dbz_frieza4", "dbs_golden_frieza"}
new cell_models[][] = { "dbz_cell1", "dbz_cell2", "dbz_cell3", "dbz_cell3" }
new broly_models[][] = { "dbz_broly2", "dbz_broly2", "dbz_broly2", "dbz_broly3", "dbz_broly4" }
new superbuu_models[][] = { "dbz_evilbuu", "dbz_superbuu", "dbz_superbuu2", "dbz_superbuu3", "dbz_kidbuu" }
#define OMEGASHENRON_MODEL "dbz_omegashenron"

new g_playermodel[33][32]
#endif

new g_playername[33][32], g_transform_mdl_id[33], cvar_bot_maxtime, cvar_bot_mintime

/*===============================================================================
[Plugin Register]
================================================================================*/
public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR) // Plugin Register
	register_cvar("dragon_ball_z_mod", VERSION, FCVAR_SERVER|FCVAR_UNLOGGED|FCVAR_SPONLY);
	
	register_dictionary("dragon_ball_mod.txt") // Lang Register

	// Events
	register_event("CurWeapon", "event_CurWeapon", "b", "1=1")
	register_message(get_user_msgid("ShowMenu"), "message_show_menu")
	register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu")
	register_menucmd(register_menuid("Terrorist_Select",1),511,"cmd_joinclass"); // Choose Team menu
	register_menucmd(register_menuid("CT_Select",1),511,"cmd_joinclass"); // Choose Team menu
	RegisterHam(Ham_Spawn, "player", "fwd_PlayerSpawn", 1)
	register_event("DeathMsg","client_death","a")
	register_event("ResetHUD", "bot_spawn", "be")
	register_clcmd("chooseteam", "protecao3");
	register_clcmd("jointeam", "protecao_jointeam");
	register_message(get_user_msgid("StatusIcon"),	"Message_StatusIcon")
	register_forward(FM_EmitSound, "fw_EmitSound")
	register_forward(FM_Touch, "fwd_Touch")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	register_message(get_user_msgid("Health"), "message_health")
	unregister_forward(FM_Spawn, fw_gSpawn);
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")

	register_touch(POWER_CLASSNAME, "*", "power_touch")
	register_think(POWER_CLASSNAME, "fw_power_think")
	
	// General Cvars
	cvar_energy_for_second = register_cvar("dbm_energy_for_second", "20") 	// Amount of energy to Earn Per Second
	cvar_energy_need = register_cvar("dbm_energy_need", "250")	// Amount of Energy Needed To Use Any Skill
	cvar_blast_decalls = register_cvar("dbm_blast_decals_enable", "1") // Enable Decals
	cvar_start_life_quantity = register_cvar("dbm_start_life_on_spawn", "1000") // How life should begin when reviving
	cvar_powerup_effect = register_cvar("dbm_powerup_effect_enable", "1") // Enable Powerup Effect

	cvar_bot_maxtime = register_cvar("dbm_bot_power_maxtime", "20") // Time of Range for Bot use the powers
	cvar_bot_mintime = register_cvar("dbm_bot_power_mintime", "5")
	
	// Cvars - Goku	
	cvar_goku[0] = register_cvar("dbm_goku_dmg_ki_blast", "50")			// Ki-Blast Damage
	cvar_goku[1] = register_cvar("dbm_goku_dmg_kamehameha", "150")		// Kamehameha Damage
	cvar_goku[2] = register_cvar("dbm_goku_dmg_dragon_first", "300")	// Dragon First Damage
	cvar_goku[3] = register_cvar("dbm_goku_dmg_10x_kamehameha", "500")	// 10x Kamehameha Damage
	cvar_goku[4] = register_cvar("dbm_goku_dmg_spirit_bomb", "700")		// Spirit Bomb Damage
	cvar_goku[5] = register_cvar("dbm_goku_rad_ki_blast", "100")		// Ki-Blast Radius
	cvar_goku[6] = register_cvar("dbm_goku_rad_kamehameha", "200")		// Kamehameha Radius
	cvar_goku[7] = register_cvar("dbm_goku_rad_dragon_first", "300")	// Dragon First Radius
	cvar_goku[8] = register_cvar("dbm_goku_rad_10x_kamehameha", "400")	// 10x Kamehameha Radius
	cvar_goku[9] = register_cvar("dbm_goku_rad_spirit_bomb", "500")		// Spirit Bomb Radius
	
	// Cvars - Vegeta
	cvar_vegeta[0] = register_cvar("dbm_vegeta_dmg_ki_blast", "50")		// Ki-Blast Damage
	cvar_vegeta[1] = register_cvar("dbm_vegeta_dmg_garlic_gun", "150")	// Garlic Gun Damage
	cvar_vegeta[2] = register_cvar("dbm_vegeta_dmg_fflash", "300")		// Final Flash Damage
	cvar_vegeta[3] = register_cvar("dbm_vegeta_dmg_fshine", "500")		// Final Shine Attack Damage
	cvar_vegeta[4] = register_cvar("dbm_vegeta_rad_ki_blast", "100")	// Ki-Blast Radius
	cvar_vegeta[5] = register_cvar("dbm_vegeta_rad_garlic_gun", "200")	// Garlic Gun Radius
	cvar_vegeta[6] = register_cvar("dbm_vegeta_rad_fflash", "300")		// Final Flash Radius
	cvar_vegeta[7] = register_cvar("dbm_vegeta_rad_fshine", "400")		// Final Shine Attack Radius
	
	// Cvars - Gohan	
	cvar_gohan[0] = register_cvar("dbm_gohan_dmg_ki_blast", "50")		// Ki-Blast Damage
	cvar_gohan[1] = register_cvar("dbm_gohan_dmg_masenko", "150")		// Masenko Damage
	cvar_gohan[2] = register_cvar("dbm_gohan_dmg_kamehameha", "300")	// Kamehameha Damage
	cvar_gohan[3] = register_cvar("dbm_gohan_rad_ki_blast", "100")		// Ki-Blast Radius
	cvar_gohan[4] = register_cvar("dbm_gohan_rad_masenko", "200")		// Masenko Radius
	cvar_gohan[5] = register_cvar("dbm_gohan_rad_kamehameha", "300")	// Kamehameha Radius
	
	// Cvars - Krillin	
	cvar_krilin[0] = register_cvar("dbm_krilin_dmg_ki_blast", "50")		// Ki-Blast Damage
	cvar_krilin[1] = register_cvar("dbm_krilin_dmg_kamehameha", "150")	// Kamehameha Damage
	cvar_krilin[2] = register_cvar("dbm_krilin_dmg_ddisc", "300")		// Destrucion Disc Damage
	cvar_krilin[3] = register_cvar("dbm_krilin_rad_ki_blast", "100")	// Ki-Blast Radius
	cvar_krilin[4] = register_cvar("dbm_krilin_rad_kamehameha", "200")	// Kamehameha Radius
	cvar_krilin[5] = register_cvar("dbm_krilin_rad_ddisc", "300")		// Destrucion Disc Radius
	
	// Cvars - Picolo	
	cvar_picolo[0] = register_cvar("dbm_picolo_dmg_ki_blast", "50")			// Ki-Blast Damage
	cvar_picolo[1] = register_cvar("dbm_picolo_dmg_masenko", "150")			// Masenko Damage
	cvar_picolo[2] = register_cvar("dbm_picolo_dmg_sbean_cannon", "300")	// Special Bean Cannon Damage
	cvar_picolo[3] = register_cvar("dbm_picolo_rad_ki_blast", "100")		// Ki-Blast Radius
	cvar_picolo[4] = register_cvar("dbm_picolo_rad_masenko", "200")			// Masenko Radius
	cvar_picolo[5] = register_cvar("dbm_picolo_rad_sbean_cannon", "300")	// Special Bean Cannon Radius
	
	// Cvars - Frieza
	cvar_frieza[0] = register_cvar("dbm_frieza_dmg_ki_blast", "50")		// Ki-Blast Damage
	cvar_frieza[1] = register_cvar("dbm_frieza_dmg_death_beam", "150")	// Death Beam Damage
	cvar_frieza[2] = register_cvar("dbm_frieza_dmg_ddisc", "300")		// Destrucion Disc Damage
	cvar_frieza[3] = register_cvar("dbm_frieza_dmg_death_ball", "500")	// Death Ball Damage
	cvar_frieza[4] = register_cvar("dbm_frieza_rad_ki_blast", "100")	// Ki-Blast Radius
	cvar_frieza[5] = register_cvar("dbm_frieza_rad_death_beam", "200")	// Death Beam Radius
	cvar_frieza[6] = register_cvar("dbm_frieza_rad_ddisc", "300")		// Destrucion Disc Radius
	cvar_frieza[7] = register_cvar("dbm_frieza_rad_death_ball", "400")	// Death Ball Radius

	// Cvars - Broly
	cvar_broly[0] = register_cvar("dbm_broly_dmg_galitgun", "50")		// Galitgun Damage
	cvar_broly[1] = register_cvar("dbm_broly_dmg_fflash", "150")		// Final Flash Damage
	cvar_broly[2] = register_cvar("dbm_broly_dmg_big_bang", "300")		// Big Bang Damage
	cvar_broly[3] = register_cvar("dbm_broly_dmg_death_ball", "500")	// Death Ball Damage
	cvar_broly[4] = register_cvar("dbm_broly_rad_ki_blast", "100")		// Galitgun Radius
	cvar_broly[5] = register_cvar("dbm_broly_rad_fflash", "200")		// Final Flash Radius
	cvar_broly[6] = register_cvar("dbm_broly_rad_big_bang", "300")		// Big Bang Radius
	cvar_broly[7] = register_cvar("dbm_broly_rad_death_ball", "400")	// Death Ball Radius
	
	// Cvars - Super Buu
	cvar_superbuu[0] = register_cvar("dbm_superbuu_dmg_galitgun", "50")		// Galitgun Damage
	cvar_superbuu[1] = register_cvar("dbm_superbuu_dmg_fflash", "150")		// Final Flash Damage
	cvar_superbuu[2] = register_cvar("dbm_superbuu_dmg_big_bang", "300")	// Big Bang Damage
	cvar_superbuu[3] = register_cvar("dbm_superbuu_dmg_death_ball", "500")	// Death Ball Damage
	cvar_superbuu[4] = register_cvar("dbm_superbuu_rad_ki_blast", "100")	// Galitgun Radius
	cvar_superbuu[5] = register_cvar("dbm_superbuu_rad_fflash", "200")		// Final Flash Radius
	cvar_superbuu[6] = register_cvar("dbm_superbuu_rad_big_bang", "300")	// Big Bang Radius
	cvar_superbuu[7] = register_cvar("dbm_superbuu_rad_death_ball", "400")	// Death Ball Radius
	
	// Cvars - Cell	
	cvar_cell[0] = register_cvar("dbm_cell_dmg_ki_blast", "50")		// Ki-Blast Damage
	cvar_cell[1] = register_cvar("dbm_cell_dmg_death_beam", "150")	// Death Beam Damage
	cvar_cell[2] = register_cvar("dbm_cell_dmg_kamehameha", "300")	// Kamehameha Damage
	cvar_cell[3] = register_cvar("dbm_cell_rad_ki_blast", "100")	// Ki-Blast Radius
	cvar_cell[4] = register_cvar("dbm_cell_rad_death_beam", "200")	// Death Beam Radius
	cvar_cell[5] = register_cvar("dbm_cell_rad_kamehameha", "300")	// Kamehameha Radius
	
	// Cvars - Omega Sheron	
	cvar_omega_sheron[0] = register_cvar("dbm_omega_dmg_ki_blast", "50")		// Ki-Blast Damage
	cvar_omega_sheron[1] = register_cvar("dbm_omega_dmg_dragon_thunder", "150")	// Dragon Thunder Damage
	cvar_omega_sheron[2] = register_cvar("dbm_omega_dmg_minus_energy", "700")	// Minus Energy Power Ball Damage
	cvar_omega_sheron[3] = register_cvar("dbm_omega_rad_ki_blast", "100")		// Ki-Blast Radius
	cvar_omega_sheron[4] = register_cvar("dbm_omega_rad_dragon_thunder", "200")	// Dragon Thunder Radius
	cvar_omega_sheron[5] = register_cvar("dbm_omega_rad_minus_energy", "300")	// Minus Energy Power Ball Radius
	
	g_msg_syc = CreateHudSyncObj()
	g_maxpl = get_maxplayers()
	
}

/*===============================================================================
[Plugin Natives]
================================================================================*/
public plugin_natives()
{
	register_native("dbz_get_user_energy", "native_get_user_energy", 1)
	register_native("dbz_set_user_energy", "native_set_user_energy", 1)
	register_native("dbz_get_user_hero_id", "native_get_user_hero_id", 1)
	register_native("dbz_get_user_villain_id", "native_get_user_villain_id", 1)
	register_native("dbz_get_energy_level", "native_get_energy_level", 1)
	register_native("dbz_set_energy_level", "native_set_energy_level", 1)
}

/*===============================================================================
[Game Description]
================================================================================*/
public fw_GetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, "Dragon Ball Mod 1.5")
	return FMRES_SUPERCEDE;
}

/*===============================================================================
[Plugin Precache]
================================================================================*/
public plugin_precache()
{
	// Goku
	precache_sound("db_mod_15/goku_ki_blast.wav")
	precache_sound("db_mod_15/goku_kamehameha.wav")
	precache_sound("db_mod_15/goku_10x_kamehameha.wav")
	precache_sound("db_mod_15/goku_spirit_bomb.wav")
	precache_sound("db_mod_15/goku_dragon_first.wav")
	precache_sound("db_mod_15/goku_powerup1.wav")
	precache_sound("db_mod_15/goku_powerup2.wav")
	precache_sound("db_mod_15/goku_powerup3.wav")
	precache_sound("db_mod_15/goku_powerup4.wav")
	precache_sound("db_mod_15/goku_powerup5.wav")

	// Frieza
	precache_sound("db_mod_15/frieza_powerup1.wav")
	precache_sound("db_mod_15/frieza_powerup2.wav")
	precache_sound("db_mod_15/frieza_powerup3.wav")
	precache_sound("db_mod_15/frieza_powerup4.wav")
	precache_sound("db_mod_15/frieza_deathball.wav")
	precache_sound("db_mod_15/frieza_destructodisc.wav")

	// Vegeta
	precache_sound("db_mod_15/vegeta_powerup1.wav")
	precache_sound("db_mod_15/vegeta_powerup2.wav")
	precache_sound("db_mod_15/vegeta_powerup3.wav")
	precache_sound("db_mod_15/vegeta_powerup4.wav")	
	precache_sound("db_mod_15/gallitgunfire.wav")
	precache_sound("db_mod_15/vegeta_finalflash.wav")
	precache_sound("db_mod_15/vegeta_final_shine.wav")

	// Gohan
	precache_sound("db_mod_15/gohan_powerup1.wav")
	precache_sound("db_mod_15/gohan_powerup2.wav")
	precache_sound("db_mod_15/gohan_powerup3.wav")
	precache_sound("db_mod_15/gohan_masenko.wav")
	precache_sound("db_mod_15/ssjgohan_kamehameha.wav")

	// Krilin
	precache_sound("db_mod_15/krillin_powerup1.wav")
	precache_sound("db_mod_15/krillin_powerup2.wav")
	precache_sound("db_mod_15/krillin_kamehameha.wav")
	precache_sound("db_mod_15/krillin_destructodisc.wav")

	// Cell
	precache_sound("db_mod_15/cell_powerup1.wav")
	precache_sound("db_mod_15/cell_powerup2.wav")
	precache_sound("db_mod_15/cell_powerup3.wav")
	precache_sound("db_mod_15/cell_kamehameha.wav")
	
	// Superbuu
	precache_sound("db_mod_15/superbuu_galitgun.wav")
	precache_sound("db_mod_15/superbuu_finalflashb_fix.wav")
	precache_sound("db_mod_15/superbuu_bigbang.wav")
	precache_sound("db_mod_15/superbuu_deathball_fix.wav")
	precache_sound("db_mod_15/superbuu_powerup1_fix.wav")
	precache_sound("db_mod_15/superbuu_powerup2.wav")
	precache_sound("db_mod_15/superbuu_powerup3.wav")

	// Piccolo
	precache_sound("db_mod_15/piccolo_masenko.wav")
	precache_sound("db_mod_15/specialbeamcannon.wav")
	precache_sound("db_mod_15/piccolo_powerup1.wav")
	precache_sound("db_mod_15/piccolo_powerup2.wav")
	precache_sound("db_mod_15/piccolo_powerup3.wav")

	// Broly
	precache_sound("db_mod_15/broly_galitgun.wav")
	precache_sound("db_mod_15/broly_finalflashb.wav")
	precache_sound("db_mod_15/broly_bigbang.wav")
	precache_sound("db_mod_15/broly_deathball.wav")
	precache_sound("db_mod_15/broly_powerup1.wav")
	precache_sound("db_mod_15/broly_powerup2.wav")
	precache_sound("db_mod_15/broly_powerup3.wav")
	precache_sound("db_mod_15/broly_powerup4.wav")

	// Omega
	precache_sound("db_mod_15/omega_powerup1.wav")
	precache_sound("db_mod_15/omega_powerup2.wav")
	precache_sound("db_mod_15/omega_powerup3.wav")
	precache_sound("db_mod_15/omega_attack2.wav")
	precache_sound("db_mod_15/omega_attack3.wav")

	precache_sound("player/pl_pain2.wav")

	spr[1] = precache_model("sprites/db_mod_15/powerup.spr")
	spr[0] = precache_model("sprites/wall_puff4.spr")

	precache_model(DBZ_KNIFE_V_MODEL)
	
	new i
	for(i = 0; i < MAX_EXPLOSION; i++) {
		g_explosion[i] = precache_model(Exp_Sprs[i])
	}
	for(i = 0; i < MAX_TRAILS; i++) {
		g_trail[i] = precache_model(Trail_Sprs[i])
	}
	for(i = 0; i < MAX_POWER_MODELS; i++) {
		precache_model(Power_Models[i])
	}
	for (i = 0; i < sizeof knife_sounds; i++) {
		precache_sound(knife_sounds[i])
	}

	// Player Models
	#if defined PLAYER_MODELS
	for (i = 0; i < sizeof goku_models; i++) {
		precache_playermodel(goku_models[i])
	}

	for (i = 0; i < sizeof vegeta_models; i++) {
		precache_playermodel(vegeta_models[i])
	}

	for (i = 0; i < sizeof gohan_models; i++) {
		precache_playermodel(gohan_models[i])
	}
	
	precache_playermodel(KRILLIN_MODEL)
	precache_playermodel(PICCOLO_MODEL)

	for (i = 0; i < sizeof frieza_models; i++) {
		precache_playermodel(frieza_models[i])
	}

	for (i = 0; i < sizeof cell_models; i++) {
		precache_playermodel(cell_models[i])
	}

	for (i = 0; i < sizeof broly_models; i++) {
		precache_playermodel(broly_models[i])
	}

	for (i = 0; i < sizeof superbuu_models; i++) {
		precache_playermodel(superbuu_models[i])
	}
	
	precache_playermodel(OMEGASHENRON_MODEL)
	#endif

	fw_gSpawn = register_forward(FM_Spawn, "fw_Spawn")
}

/*===============================================================================
[Remove Unecessary Entities]
================================================================================*/
public fw_Spawn(entity)
{
	// Invalid entity
	if(!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	static classname[32], i; pev(entity, pev_classname, classname, charsmax(classname))
	
	// Check whether it needs to be removed
	for (i = 0; i < sizeof(Remove_Entities); i++) {
		if(equal(classname, Remove_Entities[i])) {
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}	

/*===============================================================================
[Reset Variables When Player Spawn]
================================================================================*/
public fwd_PlayerSpawn(id)
{
	if(!is_user_alive(id))
		return

	client_printcolor(id, "!g--==!t Dragon Ball Z Mod %s By: [P]erfec[T] [S]cr[@]s[H] !g==--", VERSION) // Show Credits
	client_cmd(id, "stopsound") // Stop sounds

	spawn_event(id)
}


public bot_spawn(id)
{
	if(!is_user_alive(id))
		return

	// Bot Suport
	if(is_user_bot(id))	{
		switch(cs_get_user_team(id)) {
		    case CS_TEAM_T: g_villain_id[id] = random_num(1,5); // Choose villain automatically
		    case CS_TEAM_CT: g_hero_id[id] = random_num(1,5); // Choose hero automatically
		}
		spawn_event(id)
	}
}

stock spawn_event(id)
{
	if(!is_user_alive(id))
		return;

	g_is_user_alive[id] = true

	if(g_power[3][id] > 0) 
		remove_power(id, g_power[3][id]);
	
	//remove_task(id+TASK_LOOP)
	g_power[2][id] = 0
	g_power[0][id] = 0
	g_transform_mdl_id[id] = 0
	
	#if defined PLAYER_MODELS
	model_update(id)
	#endif
	
	// Bug Prevention on Auto Balance / Auto join
	if((g_villain_id[id] > 0 || g_hero_id[id] <= 0)&& cs_get_user_team(id) == CS_TEAM_CT) {
		g_villain_id[id] = 0
		g_hero_id[id] = random_num(1,5) 
	}
	if((g_hero_id[id] > 0 || g_villain_id[id] <= 0) && cs_get_user_team(id) == CS_TEAM_T ) {
		g_hero_id[id] = 0
		g_villain_id[id] = random_num(1,5) 
	}
	
	set_user_health(id, get_pcvar_num(cvar_start_life_quantity))
	
	/*static iwpn, iwpns[32], nwpn[32], a;
	get_user_weapons (id, iwpns, iwpn);
	for (a = 0; a < iwpn; ++a ) {
		get_weaponname(iwpns[a], nwpn, charsmax(nwpn)); // Use Knifes Only
		engclient_cmd(id, "drop", nwpn);
	}*/
	strip_user_weapons(id)
	give_item(id, "weapon_knife")
}


public client_death() {
	new ent_id = read_data(2) // Gets Victim ID
	
	if(is_user_valid_alive(ent_id))
		g_is_user_alive[ent_id] = false; 
}

public Message_StatusIcon(iMsgId, MSG_DEST, id) { 
	static szIcon[5] 
	get_msg_arg_string(2, szIcon, charsmax(szIcon)) 
	if(szIcon[0] == 'b' && szIcon[2] == 'y' && szIcon[3] == 'z') 
	{ 
		if(get_msg_arg_int(1)) { 
			fm_cs_set_user_nobuy(id) 
			return PLUGIN_HANDLED;
		} 
	}  
	return PLUGIN_CONTINUE;
}
/*===============================================================================
[For Use the Powers]
================================================================================*/
public use_power(id)
{
	if(!is_user_connected(id) || !is_user_valid_alive(id))
		return

	if(g_power[2][id] < g_energy_level[0]) {
		client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "DONT_HAVE_ENERGY")
		return
	}
	if(g_power[3][id]){
		client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "ONE_POWER_BY_TIME")
		return
	}
	
	if(g_hero_id[id] > 0) {
		switch(g_hero_id[id]) {
			case 1: { // Goku
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_ki_blast.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_goku[0])
					g_max[0][id] = get_pcvar_num(cvar_goku[5])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Kamehameha!!", id, "DBZ_TAG")
					// Wish this sound was shorter
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_kamehameha.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_goku[1])
					g_max[0][id] = get_pcvar_num(cvar_goku[6])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3]) {
					client_printcolor(id,"%L Dragon First!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_dragon_first.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_goku[2])
					g_max[0][id] = get_pcvar_num(cvar_goku[7])
					g_power[1][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3] && g_power[2][id] < g_energy_level[4]) {
					client_printcolor(id,"%L 10x Kamehameha!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_10x_kamehameha.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[3]
					g_max[1][id] = get_pcvar_num(cvar_goku[3])
					g_max[0][id] = get_pcvar_num(cvar_goku[8])
					g_power[1][id] = 4
				}
				else if(g_power[2][id] >= g_energy_level[4]) {
					client_printcolor(id,"%L Spirit Bomb!!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_spirit_bomb.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[4]
					g_max[1][id] = get_pcvar_num(cvar_goku[4])
					g_max[0][id] = get_pcvar_num(cvar_goku[9])
					g_power[1][id] = 5
				}
			}
			case 2:	{ // Vegeta
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_ki_blast.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_vegeta[0])
					g_max[0][id] = get_pcvar_num(cvar_vegeta[4])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Garlic Gun !!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/gallitgunfire.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_vegeta[1])
					g_max[0][id] = get_pcvar_num(cvar_vegeta[5])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3]) {
					client_printcolor(id,"%L Final Flash !!!", id, "DBZ_TAG")
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_vegeta[2])
					g_max[0][id] = get_pcvar_num(cvar_vegeta[6])
					emit_sound(id, CHAN_STATIC, "db_mod_15/vegeta_finalflash.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[1][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3]) {
					client_printcolor(id,"%L Final Shine Attack!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/vegeta_final_shine.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[3]
					g_max[1][id] = get_pcvar_num(cvar_vegeta[3])
					g_max[0][id] = get_pcvar_num(cvar_vegeta[7])
					g_power[1][id] = 4
				}
			}
			case 3:	{ // Gohan
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_ki_blast.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_gohan[0])
					g_max[0][id] = get_pcvar_num(cvar_gohan[3])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Masenko!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/gohan_masenko.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_gohan[1])
					g_max[0][id] = get_pcvar_num(cvar_gohan[4])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2]) {
					client_printcolor(id,"%L Kamehameha!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/ssjgohan_kamehameha.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_gohan[2])
					g_max[0][id] = get_pcvar_num(cvar_gohan[5])
					g_power[1][id] = 3
				}
			}
			case 4:	{ // Krilin
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_ki_blast.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_krilin[0])
					g_max[0][id] = get_pcvar_num(cvar_krilin[3])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Kamehameha !!", id, "DBZ_TAG")
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_krilin[1])
					g_max[0][id] = get_pcvar_num(cvar_krilin[4])
					g_power[1][id] = 2
					emit_sound(id, CHAN_STATIC, "db_mod_15/krillin_kamehameha.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				else if(g_power[2][id] >= g_energy_level[2]) {
					client_printcolor(id,"%L Destrucion Disc !!!", id, "DBZ_TAG")
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_krilin[2])
					g_max[0][id] = get_pcvar_num(cvar_krilin[5])
					g_power[1][id] = 3
					emit_sound(id, CHAN_STATIC, "db_mod_15/krillin_destructodisc.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case 5:	{ // Picolo
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_ki_blast.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_picolo[0])
					g_max[0][id] = get_pcvar_num(cvar_picolo[3])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Masenko !!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/piccolo_masenko.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_picolo[1])
					g_max[0][id] = get_pcvar_num(cvar_picolo[4])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2]) {
					client_printcolor(id,"%L Special Bean Cannon!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/specialbeamcannon.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_picolo[2])
					g_max[0][id] = get_pcvar_num(cvar_picolo[5])
					g_power[1][id] = 3
				}
			}
		}
	}
	else {
		switch(g_villain_id[id])
		{
			// Frieza
			case 1:	{
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_ki_blast.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id]  = get_pcvar_num(cvar_frieza[0])
					g_max[0][id] = get_pcvar_num(cvar_frieza[4])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Death Beam!!", id, "DBZ_TAG")
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id]  = get_pcvar_num(cvar_frieza[1])
					g_max[0][id] = get_pcvar_num(cvar_frieza[5])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3]) {
					client_printcolor(id,"%L Destrucion Disc !!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/frieza_destructodisc.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id]  = get_pcvar_num(cvar_frieza[2])
					g_max[0][id] = get_pcvar_num(cvar_frieza[6])
					g_power[1][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3]) {
					client_printcolor(id,"%L Death Ball!!!", id, "DBZ_TAG")
					g_power[2][id] -= g_energy_level[3]
					g_max[1][id]  = get_pcvar_num(cvar_frieza[3])
					g_max[0][id] = get_pcvar_num(cvar_frieza[7])
					g_power[1][id] = 4
					emit_sound(id, CHAN_STATIC, "db_mod_15/frieza_deathball.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		
			// Cell
			case 2:	{
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_ki_blast.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_cell[0])
					g_max[0][id] = get_pcvar_num(cvar_cell[3])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Death Beam !!", id, "DBZ_TAG")
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_cell[1])
					g_max[0][id] = get_pcvar_num(cvar_cell[4])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2]) {
					client_printcolor(id,"%L Kamehameha !!!", id, "DBZ_TAG")
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_cell[2])
					g_max[0][id] = get_pcvar_num(cvar_cell[5])
					g_power[1][id] = 3
					emit_sound(id, CHAN_STATIC, "db_mod_15/cell_kamehameha.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			// Super Buu
			case 3: {
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/superbuu_galitgun.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_superbuu[0])
					g_max[0][id] = get_pcvar_num(cvar_superbuu[4])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Final Flash!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/superbuu_finalflashb_fix.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_superbuu[1])
					g_max[0][id] = get_pcvar_num(cvar_superbuu[5])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3]) {
					client_printcolor(id,"%L Big Bang!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/superbuu_bigbang.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_superbuu[2])
					g_max[0][id] = get_pcvar_num(cvar_superbuu[6])
					g_power[1][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3]) {
					client_printcolor(id,"%L Deathball!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/superbuu_deathball_fix.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[3]
					g_max[1][id] = get_pcvar_num(cvar_superbuu[3])
					g_max[0][id] = get_pcvar_num(cvar_superbuu[7])
					g_power[1][id] = 4
				}
			}
			
			// Broly
			case 4:	{
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_broly[0])
					g_max[0][id] = get_pcvar_num(cvar_broly[4])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Final Flash!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/broly_finalflashb.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_broly[1])
					g_max[0][id] = get_pcvar_num(cvar_broly[5])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3]) {
					client_printcolor(id,"%L Big Bang!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/broly_bigbang.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_broly[2])
					g_max[0][id] = get_pcvar_num(cvar_broly[6])
					g_power[1][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3]) {
					client_printcolor(id,"%L Deathball!!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/broly_deathball.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[3]
					g_max[1][id] = get_pcvar_num(cvar_broly[3])
					g_max[0][id] = get_pcvar_num(cvar_broly[7])
					g_power[1][id] = 4
				}
			}
			
			// Omega Sheron
			case 5: {
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1]) {
					client_printcolor(id, "%L Ki Blast!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_ki_blast.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[0]
					g_max[1][id] = get_pcvar_num(cvar_omega_sheron[0])
					g_max[0][id] = get_pcvar_num(cvar_omega_sheron[3])
					g_power[1][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2]) {
					client_printcolor(id,"%L Dragon Thunder !!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/omega_attack2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[1]
					g_max[1][id] = get_pcvar_num(cvar_omega_sheron[1])
					g_max[0][id] = get_pcvar_num(cvar_omega_sheron[4])
					g_power[1][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2]) {
					client_printcolor(id,"%L Minus Energy Power Ball !!!", id, "DBZ_TAG")
					emit_sound(id, CHAN_STATIC, "db_mod_15/omega_attack3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[2][id] -= g_energy_level[2]
					g_max[1][id] = get_pcvar_num(cvar_omega_sheron[2])
					g_max[0][id] = get_pcvar_num(cvar_omega_sheron[5])
					g_power[1][id] = 3
				}
			}
		}
	}
	create_power(id)
}

/*===============================================================================
[Some Protections]
================================================================================*/
public fw_ClientUserInfoChanged(id) { // Forward Client User Info Changed
	if(!is_user_valid_connected(id))
		return;

	get_user_name(id, g_playername[id], charsmax(g_playername[])) // Cache player's name
	
	#if defined PLAYER_MODELS
	if(is_user_valid_alive(id)) {
		static currentmodel[32]; cs_get_user_model(id, currentmodel, charsmax(currentmodel)) // Get current model
		if(!equal(currentmodel, g_playermodel[id])) model_update(id) // If they're different, set model again
	}
	#endif
}
public fwd_Touch(ent, id)
{
	if(!is_user_valid_alive(id) || !pev_valid(ent)) return FMRES_IGNORED;
	
	static szEntModel[32]; pev(ent , pev_model , szEntModel , 31); 
	if(contain(szEntModel, "w_")) return FMRES_SUPERCEDE; // Don't Pick Weapons on ground
	
	return FMRES_IGNORED;
}

public message_show_menu(msgid, dest, id) 
{	
	if(g_villain_id[id] <= 0 && g_hero_id[id] <= 0) return PLUGIN_HANDLED
	
	static team_select[] = "#Team_Select"
	
	static menu_text_code[sizeof team_select]
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)
	
	if(!equal(menu_text_code, team_select)) return PLUGIN_CONTINUE
	
	static param_menu_msgid[2]
	param_menu_msgid[0] = msgid
	
	set_force_team_join_task(id, msgid)
	
	return PLUGIN_HANDLED
}

public message_vgui_menu(msgid, dest, id) 
{	
	if(get_msg_arg_int(1) != 2 || g_villain_id[id] <= 0 && g_hero_id[id] <= 0) return PLUGIN_CONTINUE
	
	static param_menu_msgid[2]
	param_menu_msgid[0] = msgid
	
	set_force_team_join_task(id, msgid)
	
	return PLUGIN_HANDLED
}

set_force_team_join_task(id, menu_msgid) 
{
	static param_menu_msgid[2]
	param_menu_msgid[0] = menu_msgid
	set_task(0.1, "task_force_team_join", id, param_menu_msgid, sizeof param_menu_msgid)
}

public task_force_team_join(menu_msgid[], id) 
{	
	static msg_block; msg_block = get_msg_block(menu_msgid[0])
	
	set_msg_block(menu_msgid[0], BLOCK_SET)
	set_msg_block(menu_msgid[0], msg_block)
}

/*===============================================================================
[Reset variables If the player connects or disconnects]
================================================================================*/
public client_disconnected(player_id)
{
	if(g_power[3][player_id] > 0)	
		remove_power(player_id, g_power[3][player_id]);

	g_villain_id[player_id] = 0
	g_hero_id[player_id] = 0
	g_power[2][player_id] = 0
	g_power[0][player_id] = 0
	g_is_user_connected[player_id] = false
	g_is_user_alive[player_id] = false
	
	#if defined PLAYER_MODELS
	remove_task(player_id+TASK_MODEL)
	#endif

	// addons_zz content
	if(is_user_bot(player_id)) {
		g_bots_count--
		
		if(!g_bots_count)
			remove_task(TASK_LOOP_BOTS)
		
		for(g_current_index = 0; g_current_index < g_bots_count; g_current_index++) {
			if(g_bots_connected[g_current_index] == player_id) {
				while(g_current_index < g_bots_count) {
					g_bots_connected[g_current_index] = g_bots_connected[g_current_index + 1]
					g_current_index++
				}
			}
		}
	}
	else {
		g_players_count--

		if(!g_players_count)
			remove_task(TASK_LOOP_PLAYERS)
		
		for(g_current_index = 0; g_current_index < g_players_count; g_current_index++) {
			if(g_players_connected[g_current_index] == player_id) {
				while(g_current_index < g_players_count) {
					g_players_connected[g_current_index] = g_players_connected[g_current_index + 1]
					g_current_index++
				}
			}
		}
	}
}

// addons_zz Content
public client_putinserver(player_id) {

	get_user_name(player_id, g_playername[player_id], charsmax(g_playername[])) // Cache player's name

	g_is_user_connected[player_id] = true

	if(is_user_bot(player_id))
	{
		g_bots_connected[g_bots_count] = player_id
		
		if(!g_bots_count)
			set_task(1.0, "iterate_through_bots", TASK_LOOP_BOTS, _, _, "b")
		
		//g_bots_power_tigger[g_bots_count] = (g_current_index < 1) ? 1 : g_current_index
		g_bots_power_allow[player_id] = random_num(get_pcvar_num(cvar_bot_mintime), get_pcvar_num(cvar_bot_maxtime))	
		g_bot_round_timer[player_id] = 0
		g_bots_count++
	}
	else {
		g_players_connected[g_players_count] = player_id
		
		if(!g_players_count)
			set_task(1.0, "iterate_through_players", TASK_LOOP_PLAYERS, _, _, "b")

		g_players_count++
	}
}

public iterate_through_players()
{
	static player_id
	static spectator_id
	
	for(g_current_index = 0; g_current_index < g_players_count; g_current_index++) {
		player_id = g_players_connected[g_current_index]
		
		if(is_user_valid_alive(player_id)) {
			ShowHUD(player_id, player_id)
			dbz_loop(player_id)
		}
		else // Player died?
		{
			// Get spectator target
			spectator_id = pev(player_id, pev_iuser2)
			
			if(is_user_valid_alive(spectator_id))
				ShowHUD(player_id, spectator_id)
		}
	}
}

public iterate_through_bots()
{
	static bot_id

	for(g_current_index = 0; g_current_index < g_bots_count; g_current_index++) {
		bot_id = g_bots_connected[g_current_index]
		
		g_bot_round_timer[bot_id]++

		if(is_user_valid_alive(bot_id)) {
			dbz_loop(bot_id)
			
			if(g_bot_round_timer[bot_id] >= g_bots_power_allow[bot_id]) {
				use_power(bot_id)
				g_bot_round_timer[bot_id] = 0
				g_bots_power_allow[bot_id] = random_num(get_pcvar_num(cvar_bot_mintime), get_pcvar_num(cvar_bot_maxtime))	

			}
		}
	}
}

/*===============================================================================
[Some Protections]
================================================================================*/
public protecao_jointeam(id)
{
	static Team; Team = get_user_team(id)
	if(Team == 0 || Team == 3 || g_hero_id[id] <= 0 && g_villain_id[id] <= 0) {
		menu_choose_team(id)
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public protecao3(id) {
	menu_choose_team(id)
	return PLUGIN_HANDLED
}

public cmd_joinclass(id) return PLUGIN_HANDLED;

/*===============================================================================
[Choose Team Menu]
================================================================================*/
public menu_choose_team(id)
{
	new szText[2000 char]
	formatex(szText, charsmax(szText), "%L %L", id, "MENU_DBZ_TAG", id, "CHOSE_TEAM_MENU_TITLE");

	new menu = menu_create(szText, "menu_choose_team_handler")

	formatex(szText, charsmax(szText), "%L", id, "CHOSE_TEAM_MENU_ITEM1");
	menu_additem(menu, szText, "1", 0)
	
	formatex(szText, charsmax(szText), "%L^n", id, "CHOSE_TEAM_MENU_ITEM2");
	menu_additem(menu, szText, "2", 0)
	
	formatex(szText, charsmax(szText), "%L", id, "CHOSE_TEAM_MENU_ITEM3");
	menu_additem(menu, szText, "3", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	if(g_hero_id[id] == 0 && g_villain_id[id] == 0) menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
	
	// Fix for AMXX custom menus
	if(pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)

	menu_display(id, menu, 0)
}

public menu_choose_team_handler(id, menu, item)
{
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	new key = str_to_num(data)
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	switch(key) {
		case 1: choose_character(id, 1)
		case 2: choose_character(id, 0)
		case 3: {
			if(is_user_valid_alive(id))
				dllfunc(DLLFunc_ClientKill, id)
				
			cs_set_user_team(id, CS_TEAM_SPECTATOR)
		}
	}

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

/*===============================================================================
[Choose Character Menu]
================================================================================*/
public choose_character(id, team)
{
	static szText[200], szItem[10], i

	formatex(szText, charsmax(szText), "%L %L", id, "MENU_DBZ_TAG", id, team == 1 ? "CHOSE_VILAN_MENU" : "CHOSE_HERO_MENU");
	new menu = menu_create(szText, "choose_character_handler")
	
	for (i = 1; i < (team == 1 ? (sizeof VillainLangs) : (sizeof HeroLangs)); i++) {
		formatex(szText, charsmax(szText), "%L", id, team == 1 ? VillainLangs[i] : HeroLangs[i])
		formatex(szItem, charsmax(szItem), "%s:%d", team == 1 ? "V" : "H", i)
		menu_additem(menu, szText, szItem, 0)
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	// Fix for AMXX custom menus
	if(pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menu, 0)
}


public choose_character_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	static data[6], iName[64], access, callback, key
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	key = str_to_num(data[2])

	if(g_power[3][id] > 0) 
		remove_power(id, g_power[3][id]);
	
	if(is_user_valid_alive(id)) 
		dllfunc(DLLFunc_ClientKill, id);
	
	g_power[2][id] = 0
	g_power[0][id] = 0

	if(equal(data, "V:", 2)) {
		if(g_hero_id[id] > 0 || g_villain_id[id] != key)
		{
			g_hero_id[id] = 0
			g_villain_id[id] = key
			cs_set_user_team(id, CS_TEAM_T)
			client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "CHOSED_CHARACTER", id, VillainLangs[g_villain_id[id]])
		}
		engclient_cmd(id,"jointeam","1") 
		engclient_cmd(id,"joinclass","1")
	}
	else {
		if(g_villain_id[id] > 0 || g_hero_id[id] != key)
		{		
			g_villain_id[id] = 0
			g_hero_id[id] = key
			cs_set_user_team(id, CS_TEAM_CT)
			client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "CHOSED_CHARACTER", id, HeroLangs[g_hero_id[id]])
		}
		engclient_cmd(id,"jointeam","2") 
		engclient_cmd(id,"joinclass","2")
	}

	//remove_task(id+TASK_LOOP)
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

/*=======================================================================
[HUD Info Task]
=======================================================================*/
public ShowHUD(player_id, spectator_id)
{
	if(!is_user_valid_connected(player_id) || !is_user_valid_alive(spectator_id))
		return;
	
	switch(cs_get_user_team(spectator_id)) {
		case CS_TEAM_T: {
			set_hudmessage(255, 69, 0, -1.0, 0.7, 0, 0.0, 1.1, 0.0, 0.0, 2)
			ShowSyncHudMsg(player_id, g_msg_syc, "%L", player_id, "HUD_INFO", g_playername[spectator_id], spectator_id, VillainLangs[g_villain_id[spectator_id]], get_user_health(spectator_id), g_power[2][spectator_id], g_power[0][spectator_id])
		}
		case CS_TEAM_CT: {
			set_hudmessage(0, 255, 255, -1.0, 0.7, 0, 0.0, 1.1, 0.0, 0.0, 2)
			ShowSyncHudMsg(player_id, g_msg_syc, "%L", player_id, "HUD_INFO", g_playername[spectator_id], spectator_id, HeroLangs[g_hero_id[spectator_id]], get_user_health(spectator_id), g_power[2][spectator_id], g_power[0][spectator_id])
		}
	}
}

/*===============================================================================
[Create Entity Power]
================================================================================*/
public create_power(id)
{
	static Float:vOrigin[3], Float:vAngles[3], Float:vAngle[3], entModel
	static Float:entScale, Float:entSpeed, trailModel, trailLength, trailWidth, allow_trail, allow_guide, big_attack
	static VecMins[3], VecMaxs[3], Float:FVecMins[3], Float:FVecMaxs[3]
	static trail_rgb[3], ismdl, body

	g_power[0][id] = 0
	entScale = 0.20; entSpeed = 1500.0; entModel = 6
	trail_rgb = { 235, 235, 0 }; trailModel = g_trail[0];
	trailLength = 100; trailWidth = 8
	VecMins = { -1, -1, -1 }; VecMaxs = { 1, 1, 1 }
	big_attack = false; allow_guide = true; allow_trail = true
	ismdl = 0; body = 0
	
	// Seting entSpeed higher then 2000.0 will not go where you aim
	// Vec Mins/Maxes must be below +-5.0 to make a burndecal
	if(g_hero_id[id] > 0) {
		switch(g_hero_id[id]) {
			case 1:	{ // Goku
				switch(g_power[1][id]) {
					case 1: { // Ki-Blast
						entModel = 0; entSpeed = 2000.0;
						allow_guide = false; trailLength = 1; trailWidth = 2
					}
					case 2: { // Kamehameha
						entModel = 1; entScale = 1.20;  trail_rgb = { 0, 120, 235 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: { // Dragon First
						entModel = 5; entScale = 2.00; trailModel = g_trail[1]
						trailWidth = 16; VecMins = { -3, -3, -3 }; VecMaxs = { 3, 3, 3 };
					}
					case 4: { // 10x Kamehameha
						entModel = 2; entScale = 2.00; entSpeed = 1000.0; 
						trailWidth = 16; trail_rgb = { 235, 30, 30 }
						VecMins = { -3, -3, -3 }; VecMaxs = { 3, 3, 3 }
					}
					case 5: { // Spirit Bomb
						entModel = 4; allow_trail = false; allow_guide = false
						entScale = 0.70; entSpeed = 800.0; big_attack = true
						VecMins = { -4, -4, -4 }; VecMaxs = { 4, 4, 4 };
					}
				}
			}
			case 2: { // Vegeta
				switch(g_power[1][id]) {
					case 1: { // Ki-Blast
						entSpeed = 2000.0; allow_guide = false
						trailLength = 1; trailWidth = 2; trail_rgb = { 155, 0, 235 }
					}
					case 2: { // Garlic Gun
						entScale = 1.20; trail_rgb = { 155, 0, 235 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: { // Final Flash
						entModel = 8; entScale = 0.60; entSpeed = 1600.0;
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 4: { // Final Shine Attack
						entModel = 3; entScale = 1.0; entSpeed = 1050.0
						trailWidth = 16; trail_rgb = { 0, 200, 100 }
						VecMins = { -3, -3, -3 }; VecMaxs = { 3, 3, 3 }
					}
				}
			}
			case 3: { // Gohan
				switch(g_power[1][id]) {
					case 1: { // Ki-Blast
						entModel = 0; entSpeed = 2000.0; 
						allow_guide = false; trailLength = 1; trailWidth = 2
					}
					case 2: { // Masenko
						entModel = 0; entScale = 1.20;  
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: { // Kamehameha
						entModel = 1; entScale = 1.20; trail_rgb = { 0, 120, 235 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}					
				}
			}
			case 4:	{ // Krilin
				switch(g_power[1][id]) {
					case 1: { // Ki-Blast
						entModel = 0; entSpeed = 2000.0; 
						allow_guide = false; trailLength = 1; trailWidth = 2
					}
					case 2: { // Kamehameha
						entModel = 1; entScale = 1.20; trail_rgb = { 0, 120, 235 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: { // Destruction Disc
						entModel = 16; entScale = 1.20; ismdl = 1; body = 1
						trailModel = g_trail[2]; trail_rgb = { 255, 255, 255 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
				}
			}
			case 5: { // Piccolo
				switch(g_power[1][id]) {
					case 1: { // Ki-Blast
						entModel = 3; entSpeed = 2000.0; allow_guide = false
						trailLength = 1; trailWidth = 2; trail_rgb = { 0, 200, 100 }
					}
					case 2: { // Masenko
						entModel = 0; entScale = 1.20;  
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: { // Special Bean Cannon
						allow_guide = false; trailModel = g_trail[1]; trailWidth = 2
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 }; trail_rgb = { 155, 0, 235 }
					}
				}
			}
		}
	}
	else {
		switch(g_villain_id[id]) {
			case 1: { // Frieza
				switch(g_power[1][id]) {
					case 1: { // Ki-Blast
						entSpeed = 2000.0; allow_guide = false
						trailLength = 1; trailWidth = 2; trail_rgb = { 155, 0, 235 }
					}
					case 2: { // Death Bean
						trailModel = g_trail[1]; trailWidth = 4; trail_rgb = { 155, 0, 235 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: { // Destrucion Disc (Purple)
						entModel = 16; entScale = 1.20; ismdl = 1
						trailModel = g_trail[2]; trail_rgb = { 255, 0, 255 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 4: { // Death Ball
						entModel = 7; entScale = 1.4; entSpeed = 800.0; 
						big_attack = true; allow_trail = false; allow_guide = false
						VecMins = { -4, -4, -4 }; VecMaxs = { 4, 4, 4 };
					}
				}
			}
			case 2: { // Cell
				switch(g_power[1][id]) {
					case 1: { // Ki-Blast
						entModel = 3; entSpeed = 2000.0; allow_guide = false
						trailLength = 1; trailWidth = 2; trail_rgb = { 0, 200, 100 }
					}
					case 2: { // Death Bean
						trailWidth = 4; trail_rgb = { 155, 0, 235 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: { // Green Kamehameha
						entModel = 3; entScale = 1.20; trail_rgb = { 0, 200, 100 }
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
						
					}
					
				}
			}
			case 3: { // Super Buu
				switch(g_power[1][id]) {
					case 1: { // Ki Blast
						entSpeed = 2000.0; trailModel = g_trail[1]; allow_guide = false
						trailLength = 1; trailWidth = 2; trail_rgb = { 255, 0, 255 }
					}
					case 2: { 
						entModel = 11; entScale = 0.60; entSpeed = 1600.0; 
						VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
						trail_rgb = { 255, 0, 255 }; trailModel = g_trail[1]
					}
					case 3: {
						entModel = 12; entScale = 1.0; entSpeed = 1050.0; 
						allow_trail = true; trailModel = g_trail[1]; trailWidth = 16
						trail_rgb = { 255, 0, 255 }; VecMins = { -3, -3, -3 }; VecMaxs = { 3, 3, 3 };
					}
					case 4: {
						entModel = 13; entScale = 1.70; entSpeed = 850.0; 
						big_attack = true; allow_trail = false; allow_guide = false
						VecMins = { -4, -4, -4 }; VecMaxs = { 4, 4, 4 };
					}
				}
			}
			case 4: { // Broly
				switch(g_power[1][id]) {
					case 1: {
						entModel = 3; entSpeed = 2000.0; trailModel = g_trail[1]; allow_guide = false
						trailLength = 1; trailWidth = 2; trail_rgb = { 0, 200, 100 }
					}
					case 2: {
						entModel = 8; entScale = 0.60; entSpeed = 1600.0; 
						trail_rgb = { 0, 200, 100 }; VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: {
						entModel = 9; entScale = 1.0; entSpeed = 1050.0; 
						trailWidth = 16; trail_rgb = { 0, 200, 100 }
						VecMins = { -3, -3, -3 }; VecMaxs = { 3, 3, 3 }
					}
					case 4: {
						entModel = 10; entScale = 1.70; entSpeed = 850.0; 
						big_attack = true; allow_trail = false; allow_guide = false
						VecMins = { -4, -4, -4 }; VecMaxs = { 4, 4, 4 };
					}
				}
			}
			case 5: { // Omega Sheron
				switch(g_power[1][id]) {
					case 1: { // Ki-Blast
						entModel = 1; entSpeed = 2000.0; trailModel = g_trail[1]; allow_guide = false
						trailLength = 1; trailWidth = 2
					}
					case 2: { // Dragon Thunder
						entModel = 15; entScale = 1.00; trailModel = g_trail[1]; trailWidth = 2
						trail_rgb = { 255, 255, 255 }; VecMins = { -2, -2, -2 }; VecMaxs = { 2, 2, 2 };
					}
					case 3: { // Minus Energy Power Ball
						entModel = 14; entScale = 0.70; entSpeed = 800.0; 
						big_attack = true; allow_trail = false; allow_guide = false
						VecMins = { -4, -4, -4 }; VecMaxs = { 4, 4, 4 };
					}
				}
			}
		}
	}
	
	
	// Get users postion and angles
	entity_get_vector(id, EV_VEC_origin, vOrigin)
	entity_get_vector(id, EV_VEC_angles, vAngles)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	// Change height for entity origin
	if(big_attack) vOrigin[2] += 110
	else vOrigin[2] += 6
	
	new newEnt = create_entity("info_target")
	if(newEnt == 0) {
		client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "ENTITY_FAIL")
		return
	}
	
	g_power[3][id] = newEnt
	
	entity_set_string(newEnt, EV_SZ_classname, POWER_CLASSNAME)
	entity_set_model(newEnt, Power_Models[entModel])
	
	IVecFVec(VecMins, FVecMins);
	IVecFVec(VecMaxs, FVecMaxs);

	entity_set_vector(newEnt, EV_VEC_mins, FVecMins)
	entity_set_vector(newEnt, EV_VEC_maxs, FVecMaxs)
	
	entity_set_origin(newEnt, vOrigin)
	entity_set_vector(newEnt, EV_VEC_angles, vAngles)
	entity_set_vector(newEnt, EV_VEC_v_angle, vAngle)
	
	entity_set_int(newEnt, EV_INT_solid, 2)
	entity_set_int(newEnt, EV_INT_movetype, 5)
	entity_set_int(newEnt, EV_INT_rendermode, 5)
	entity_set_float(newEnt, EV_FL_renderamt, 255.0)
	entity_set_float(newEnt, EV_FL_scale, entScale)
	entity_set_edict(newEnt, EV_ENT_owner, id)
	
	if(ismdl) {	
		entity_set_float(newEnt, EV_FL_animtime, get_gametime()); 
		entity_set_float(newEnt, EV_FL_framerate, 1.0); 
		entity_set_float(newEnt, EV_FL_frame, 0.0); 
		entity_set_int(newEnt, EV_INT_sequence, 0); 
		entity_set_int(newEnt, EV_INT_skin, body)
	}
	
	// Create a VelocityByAim() function, but instead of users
	// eyesight make it start from the entity's origin - vittu
	new Float:fl_Velocity[3], AimVec[3], velOrigin[3]
	
	FVecIVec(vOrigin, velOrigin)
	
	get_user_origin(id, AimVec, 3)
	
	new distance = get_distance(velOrigin, AimVec)
	
	// Stupid Check but lets make sure you don't devide by 0
	if(!distance) distance = 1
	
	new Float:invTime = entSpeed / distance
	
	fl_Velocity[0] = (AimVec[0] - vOrigin[0]) * invTime
	fl_Velocity[1] = (AimVec[1] - vOrigin[1]) * invTime
	fl_Velocity[2] = (AimVec[2] - vOrigin[2]) * invTime
	
	entity_set_vector(newEnt, EV_VEC_velocity, fl_Velocity)
	
	// No trail on Spirit Bomb/Death ball/etc...
	if(allow_trail) {
		// Set Trail on entity
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(22)			// TE_BEAMFOLLOW
		write_short(newEnt)		// entity:attachment to follow
		write_short(trailModel)	// sprite index
		write_byte(trailLength)	// life in 0.1's
		write_byte(trailWidth)	// line width in 0.1's
		write_byte(trail_rgb[0])	//colour
		write_byte(trail_rgb[1])
		write_byte(trail_rgb[2])
		write_byte(255)	// brightness
		message_end()
	}
	
	// Guide Kamehameha with mouse
	if(allow_guide) {
		entity_set_float(newEnt, EV_FL_fuser4, entSpeed)
		entity_set_float(newEnt, EV_FL_nextthink, get_gametime() + 0.1)
	}
}

/*===============================================================================
[Guide Kamehameha With Mouse]
================================================================================*/
public fw_power_think(ent)
{
	if(!is_valid_ent(ent)) 
		return FMRES_IGNORED;

	static id, speed, Float:Velocity[3], Float:NewAngle[3];
	id = entity_get_edict(ent, EV_ENT_owner)
	if(!is_user_valid_connected(id)) {
		power_touch(ent, 0)
		return FMRES_IGNORED
	}

	speed = floatround(entity_get_float(ent, EV_FL_fuser4))

	VelocityByAim(id, speed, Velocity)
	entity_set_vector(ent, EV_VEC_velocity, Velocity)
		
	entity_get_vector(id, EV_VEC_v_angle, NewAngle)
	entity_set_vector(ent, EV_VEC_angles, NewAngle)
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1)
	return FMRES_IGNORED;
}

/* // Old Method
public fw_power_think(ent)
{
	if(!is_valid_ent(ent)) 
		return FMRES_IGNORED;

	static id, speed, Float:fl_Velocity[3], Velocity[3]
	id = entity_get_edict(ent, EV_ENT_owner)
	if(!is_user_valid_connected(id)) {
		power_touch(ent, 0)
		return FMRES_IGNORED
	}

	speed = floatround(entity_get_float(ent, EV_FL_fuser4))

	static AimVec[3], avgFactor, Float:fl_origin[3]

	get_user_origin(id, AimVec, 3)
	
	entity_get_vector(ent, EV_VEC_origin, fl_origin)
	entity_get_vector(ent, EV_VEC_velocity, fl_Velocity)
	FVecIVec(fl_Velocity, Velocity)
	
	static iNewVelocity[3], origin[3]
	
	origin[0] = floatround(fl_origin[0])
	origin[1] = floatround(fl_origin[1])
	origin[2] = floatround(fl_origin[2])
	
	if (g_power[1][id] == 2)
		avgFactor = 3
	else if (g_power[1][id] == 3)
		avgFactor = 6
	
	else
		avgFactor = 8 // stupid check but why not
	
	static velocityVec[3], length
	
	velocityVec[0] = AimVec[0]-origin[0]
	velocityVec[1] = AimVec[1]-origin[1]
	velocityVec[2] = AimVec[2]-origin[2]
	
	length = sqroot(velocityVec[0]*velocityVec[0] + velocityVec[1]*velocityVec[1] + velocityVec[2]*velocityVec[2])
	// Stupid Check but lets make sure you don't devide by 0
	if (!length) length = 1
	
	velocityVec[0] = velocityVec[0]*speed/length
	velocityVec[1] = velocityVec[1]*speed/length
	velocityVec[2] = velocityVec[2]*speed/length
	
	iNewVelocity[0] = (velocityVec[0] + (Velocity[0] * (avgFactor-1))) / avgFactor
	iNewVelocity[1] = (velocityVec[1] + (Velocity[1] * (avgFactor-1))) / avgFactor
	iNewVelocity[2] = (velocityVec[2] + (Velocity[2] * (avgFactor-1))) / avgFactor
	
	IVecFVec(iNewVelocity, fl_Velocity);	
	entity_set_vector(ent, EV_VEC_velocity, fl_Velocity)
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1)
	return FMRES_IGNORED;
}
*/
/*===============================================================================
[Shares at the time that the power touches anything]
================================================================================*/
public power_touch(pToucher, pTouched) {
	
	if(!is_valid_ent(pToucher) || pToucher <= 0) 
		return FMRES_IGNORED;
	
	static id, dmgRadius, maxDamage, Float:fl_vExplodeAt[3], damageName[32], spriteExp
	id = entity_get_edict(pToucher, EV_ENT_owner)
	dmgRadius = g_max[0][id]
	maxDamage = g_max[1][id]
	spriteExp = g_explosion[0]
			
	if(g_hero_id[id] > 0) {
		switch(g_hero_id[id]) {
			case 1: { // Goku
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast"
					case 2: damageName = "Kamehameha", spriteExp = g_explosion[1]
					case 3: damageName = "Dragon First"
					case 4: damageName = "10x Kamehameha", spriteExp = g_explosion[2]
					case 5: damageName = "Spirit Bomb"
				}
			}
			case 2: { // Vegeta
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast", spriteExp = g_explosion[3]
					case 2: damageName = "Garlic Gun", spriteExp = g_explosion[3]
					case 3: damageName = "Final Flash", spriteExp = g_explosion[0]
					case 4: damageName = "Final Shine Attack", spriteExp = g_explosion[4]
				}
			}
			case 3: { // Gohan
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast"
					case 2: damageName = "Masenko"
					case 3: damageName = "Kamehameha", spriteExp = g_explosion[1]
				}
			}
			case 4: { // Krilin
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast"
					case 2: damageName = "Kamehameha", spriteExp = g_explosion[1]
					case 3: damageName = "Destrucion Disc"
				}
			}
			case 5: { // Picolo
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast", spriteExp = g_explosion[4]
					case 2: damageName = "Masenko"
					case 3: damageName = "Special Bean Cannon", spriteExp = g_explosion[3]
				}
			}
		}
	}
	else {
		switch(g_villain_id[id]) {
			case 1: { // Frieza
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast", spriteExp = g_explosion[3]
					case 2: damageName = "Death Bean", spriteExp = g_explosion[3]
					case 3: damageName = "Destruction Disc", spriteExp = g_explosion[3]
					case 4: damageName = "Death Ball", spriteExp = g_explosion[2]
				}
			}
			case 2: { // Cell
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast", spriteExp = g_explosion[4]
					case 2: damageName = "Death Bean", spriteExp = g_explosion[3]
					case 3: damageName = "Kamehameha", spriteExp = g_explosion[4]
				}
			}
			case 3: { // Super Buu
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast", spriteExp = g_explosion[3]
					case 2: damageName = "Final Flash", spriteExp = g_explosion[3]
					case 3: damageName = "Big Bang", spriteExp = g_explosion[3]
					case 4: damageName = "Deathball", spriteExp = g_explosion[3]
				}
				spriteExp = g_explosion[3]
			}
			case 4: { // Broly
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast", spriteExp = g_explosion[4]
					case 2: damageName = "Final Flash", spriteExp = g_explosion[4]
					case 3: damageName = "Big Bang", spriteExp = g_explosion[4]
					case 4: damageName = "Deathball", spriteExp = g_explosion[4]
				}
				spriteExp = g_explosion[4]
			}
			case 5: { // Omega Sheron
				switch(g_power[1][id]){
					case 1: damageName = "Ki Blast", spriteExp = g_explosion[1]
					case 2: damageName = "Dragon Thunder"
					case 3: damageName = "Minus Energy Power Ball", spriteExp = g_explosion[2]
				}
			}
		}
	}
	
	entity_get_vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
	
	static vExplodeAt[3]; 
	FVecIVec(fl_vExplodeAt, vExplodeAt)
	
	// Cause the Damage
	static vicOrigin[3], Float:dRatio,  distance, damage, victim
	victim = -1
	
	while((victim = find_ent_in_sphere(victim, fl_vExplodeAt, float(dmgRadius))) != 0) {

		if(!is_user_valid_alive(victim) || !is_user_valid_connected(id))
			continue;

		if(cs_get_user_team(id) == cs_get_user_team(victim) || victim == id) 
			continue;
		
		get_user_origin(victim, vicOrigin); 
		distance = get_distance(vExplodeAt, vicOrigin)
		dRatio = floatdiv(float(distance), float(dmgRadius))
		damage = maxDamage - floatround(maxDamage * dRatio)
			
		if(damage <= 0)
			continue; 

		// Set Damage
		extra_dmg(victim, id, damage, damageName)
			
		// Make them feel it
		emit_sound(victim, CHAN_BODY, "player/pl_pain2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			
		static Float:fl_Time, Float:fl_vicVelocity[3], i
		fl_Time = distance / 125.0

		for(i = 0; i < 3; i++)
			fl_vicVelocity[i] = (vicOrigin[i] - vExplodeAt[i]) / fl_Time

		entity_set_vector(victim, EV_VEC_velocity, fl_vicVelocity)
	}
	
	// Make some Effects
	static blastSize
	blastSize = floatround(dmgRadius / 12.0)
	
	// Explosion Sprite
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(23)			//TE_GLOWSPRITE
	write_coord(vExplodeAt[0])
	write_coord(vExplodeAt[1])
	write_coord(vExplodeAt[2])
	write_short(spriteExp)	// model
	write_byte(1)			// life 0.x sec
	write_byte(blastSize)	// size
	write_byte(255)		// brightness
	message_end()
	
	// Explosion (smoke, sound/effects)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(3)			//TE_EXPLOSION
	write_coord(vExplodeAt[0])
	write_coord(vExplodeAt[1])
	write_coord(vExplodeAt[2])
	write_short(spr[0])		// model
	write_byte(blastSize+5)	// scale in 0.1's
	write_byte(20)			// framerate
	write_byte(10)			// flags
	message_end()
	
	// Create Burn Decals, if they are used
	if(get_pcvar_num(cvar_blast_decalls) == 1) {
		// Change burn decal according to blast size
		static decal_id
		if(blastSize <= 18) decal_id = g_burnDecal[random_num(0,2)]
		else decal_id = g_burnDecalBig[random_num(0,2)]
		
		// Create the burn decal
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(109)		//TE_GUNSHOTDECAL
		write_coord(vExplodeAt[0])
		write_coord(vExplodeAt[1])
		write_coord(vExplodeAt[2])
		write_short(0)
		write_byte(decal_id)	//decal
		message_end()
	}
	
	remove_entity(pToucher)
	
	// Reset the Varibles
	g_power[1][id] = 0
	g_power[3][id] = 0

	return FMRES_IGNORED;

}

/*===============================================================================
[Remove Power Entity]
================================================================================*/
public remove_power(id, powerID)
{
	if(!is_valid_ent(powerID))
		return;

	static Float:fl_vOrigin[3]
	
	entity_get_vector(powerID, EV_VEC_origin, fl_vOrigin)
	
	// Create an effect of kamehameha being removed
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(14)		//TE_IMPLOSION
	write_coord(floatround(fl_vOrigin[0]))
	write_coord(floatround(fl_vOrigin[1]))
	write_coord(floatround(fl_vOrigin[2]))
	write_byte(200)	// radius
	write_byte(40)		// count
	write_byte(45)		// life in 0.1's
	message_end()
	
	g_power[1][id] = 0
	g_power[3][id] = 0
	
	remove_entity(powerID)
}

/*===============================================================================
[Energy gain every second and if Transforming]
================================================================================*/
public dbz_loop(id)
{
	//id -= TASK_LOOP

	//ShowHUD(id);

	if(!is_user_valid_alive(id)) 
		return;

	static args[2]; 
	args[0] = id; 
	args[1] = 0
	
	if(g_hero_id[id] > 0) {
		switch(g_hero_id[id]) {
			case 1: { // Goku
				if(g_power[2][id] < g_energy_level[4]) 
					g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0
		
				else if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 5
					set_hudmessage(255, 255, 100, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Goku] %L", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 7
					set_hudmessage(222, 226, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Goku] %L 2", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3] && g_power[0][id] < 3) {
					args[1] = 9
					set_hudmessage(248, 220, 117, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Goku] %L 3", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3] && g_power[2][id] < g_energy_level[4] && g_power[0][id] < 4) {
					args[1] = 11
					set_hudmessage(196, 0, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Goku] %L 4", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_powerup4.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 4
				}
				
				else if(g_power[2][id] >= g_energy_level[4] && g_power[0][id] < 5) {
					args[1] = 20
					set_hudmessage(255, 255, 255, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(0, "[Goku] %L", LANG_PLAYER, "GOKU_MIGGATE", g_playername[id])
					emit_sound(id, CHAN_STATIC, "db_mod_15/goku_powerup5.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 5
				}
			}
			case 2: { // Vegeta
				if(g_power[2][id] < g_energy_level[3]) g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0
				
				else if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 5
					set_hudmessage(255, 255, 100, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Vegeta] %L", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/vegeta_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 7
					set_hudmessage(222, 226, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Vegeta] %L 2", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/vegeta_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3] && g_power[0][id] < 3) {
					args[1] = 9
					set_hudmessage(0, 100, 255, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Vegeta] %L Blue", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/vegeta_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3] && g_power[0][id] < 4) {
					args[1] = 11
					set_hudmessage(196, 0, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(0, "[Vegeta] %L 4", LANG_PLAYER, "MAX_TURNED_SUPER_SAYAN", g_playername[id])
					emit_sound(id, CHAN_STATIC, "db_mod_15/vegeta_powerup4.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 4
				}
			}
			case 3: { // Gohan

				if(g_power[2][id] < g_energy_level[2]) g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0

				else if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 5
					client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "KI_BLAST_PREPARED")
					g_power[0][id] = 1
					emit_sound(id, CHAN_STATIC, "db_mod_15/gohan_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 7
					set_hudmessage(222, 226, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Gohan] %L", id, "TURNED_SUPER_SAYAN")
					g_power[0][id] = 2
					emit_sound(id, CHAN_STATIC, "db_mod_15/gohan_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[0][id] < 3) {
					args[1] = 11
					set_hudmessage(248, 220, 117, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(0, "[Gohan] %L 2", LANG_PLAYER, "MAX_TURNED_SUPER_SAYAN", g_playername[id])
					g_power[0][id] = 3
					emit_sound(id, CHAN_STATIC, "db_mod_15/gohan_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case 4: { // Krilin
				if(g_power[2][id] < g_energy_level[2]) 
					g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0
				
				else if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 5
					client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "KI_BLAST_PREPARED")
					g_power[0][id] = 1
					emit_sound(id, CHAN_STATIC, "db_mod_15/krillin_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 7
					client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "KAMEHAMEHA_PREPARED")
					g_power[0][id] = 2
					emit_sound(id, CHAN_STATIC, "db_mod_15/krillin_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[0][id] < 3) {
					args[1] = 9
					client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "DESTRUCION_DISC_PREPARED")
					g_power[0][id] = 3
					emit_sound(id, CHAN_STATIC, "db_mod_15/krillin_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case 5: { // Picolo
				if(g_power[2][id] < g_energy_level[2]) 
					g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0
				
				else if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 5
					client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "KI_BLAST_PREPARED")
					emit_sound(id, CHAN_STATIC, "db_mod_15/piccolo_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 7
					client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "MASENKO_PREPARED")
					emit_sound(id, CHAN_STATIC, "db_mod_15/piccolo_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[0][id] < 3) {
					args[1] = 9
					client_printcolor(id, "%L %L", id, "DBZ_TAG", id, "SPECIAL_BEAN_PREPARED")
					emit_sound(id, CHAN_STATIC, "db_mod_15/piccolo_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 3
				}
			}
		}
	}
	else if(g_villain_id[id] > 0) {
		switch(g_villain_id[id]) {
			case 1: { // Frieza
				if(g_power[2][id] < g_energy_level[3]) 
					g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0

				else if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 5
					set_hudmessage(255, 0, 255, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Frieza] %L", id, "FRIEZA_TRANSFORM_1")
					emit_sound(id, CHAN_STATIC, "db_mod_15/frieza_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 7
					set_hudmessage(255, 0, 255, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Frieza] %L", id, "FRIEZA_TRANSFORM_2")
					emit_sound(id, CHAN_STATIC, "db_mod_15/frieza_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3] && g_power[0][id] < 3) {
					args[1] = 9
					set_hudmessage(255, 0, 255, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Frieza] %L", id, "FRIEZA_TRANSFORM_3")
					emit_sound(id, CHAN_STATIC, "db_mod_15/frieza_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3] && g_power[0][id] < 4) {
					args[1] = 11
					set_hudmessage(200, 200, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(0, "[Frieza] %L", LANG_PLAYER, "FRIEZA_TRANSFORM_4", g_playername[id])
					emit_sound(id, CHAN_STATIC, "db_mod_15/frieza_powerup4.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 4
				}
			}
			case 2: { // Cell
				if(g_power[2][id] < g_energy_level[2]) 
					g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0

				else if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 5
					set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Cell] %L", id, "CELL_TRANSFORM_1")
					g_power[0][id] = 1
					emit_sound(id, CHAN_STATIC, "db_mod_15/cell_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 7
					set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Cell] %L", id, "CELL_TRANSFORM_2")
					g_power[0][id] = 2
					emit_sound(id, CHAN_STATIC, "db_mod_15/cell_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[0][id] < 3) {
					args[1] = 9
					set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(0, "[Cell] %L", LANG_PLAYER, "CELL_TRANSFORM_3", g_playername[id])
					g_power[0][id] = 3
					emit_sound(id, CHAN_STATIC, "db_mod_15/cell_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case 3: { // Super Buu
				if(g_power[2][id] < g_energy_level[3]) 
					g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0
					
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 7
					emit_sound(id, CHAN_STATIC, "db_mod_15/superbuu_powerup1_fix.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Superbuu] %L", id, "SUPER_BUU_TRASNFORM")
					g_power[0][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) 
				{
					args[1] = 11
					set_hudmessage(255, 165, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Superbuu] %L 2", id, "SUPER_BUU_TRASNFORM")
					emit_sound(id, CHAN_STATIC, "db_mod_15/superbuu_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3] && g_power[0][id] < 3) {
					args[1] = 15
					set_hudmessage(0, 255, 255, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Superbuu] %L 3", id, "SUPER_BUU_TRASNFORM")
					emit_sound(id, CHAN_STATIC, "db_mod_15/superbuu_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3] && g_power[0][id] < 4) {
					args[1] = 20
					set_hudmessage(255, 165, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					emit_sound(id, CHAN_STATIC, "db_mod_15/superbuu_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					show_hudmessage(id, "[Superbuu] %L 4", id, "SUPER_BUU_TRASNFORM")
					g_power[0][id] = 4
				}
			}
			case 4: { // Broly
				if(g_power[2][id] < g_energy_level[3]) 
					g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0
				
				if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 7
					set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Broly] %L", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/broly_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 9
					set_hudmessage(255, 165, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Broly] %L 2", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/broly_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[2][id] < g_energy_level[3] && g_power[0][id] < 3) {
					args[1] = 11
					set_hudmessage(0, 255, 255, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Broly] %L 3", id, "TURNED_SUPER_SAYAN")
					emit_sound(id, CHAN_STATIC, "db_mod_15/broly_powerup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_power[0][id] = 3
				}
				else if(g_power[2][id] >= g_energy_level[3] && g_power[0][id] < 4) {
					args[1] = 20
					set_hudmessage(255, 165, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(0, "[Broly] %L 4", LANG_PLAYER, "MAX_TURNED_SUPER_SAYAN", g_playername[id])
					emit_sound(id, CHAN_STATIC, "db_mod_15/broly_powerup4.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)         
					g_power[0][id] = 4
				}
			}
			case 5: { // Omega Sheron
				if(g_power[2][id] < g_energy_level[2]) 
					g_power[2][id] += get_pcvar_num(cvar_energy_for_second)
				
				if(g_power[2][id] < g_energy_level[0] && g_power[0][id] > 0) 
					g_power[0][id] = 0

				else if(g_power[2][id] >= g_energy_level[0] && g_power[2][id] < g_energy_level[1] && g_power[0][id] < 1) {
					args[1] = 5
					set_hudmessage(255, 69, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Omega Sheron] %L", id, "OMEGA_SHERON_TRANSFORM_1")
					emit_sound(id, CHAN_STATIC, "db_mod_15/omega_powerup1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM) 
					g_power[0][id] = 1
				}
				else if(g_power[2][id] >= g_energy_level[1] && g_power[2][id] < g_energy_level[2] && g_power[0][id] < 2) {
					args[1] = 10
					set_hudmessage(255, 69, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(id, "[Omega Sheron] %L", id, "OMEGA_SHERON_TRANSFORM_2")
					emit_sound(id, CHAN_STATIC, "db_mod_15/omega_powerup2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM) 
					g_power[0][id] = 2
				}
				else if(g_power[2][id] >= g_energy_level[2] && g_power[0][id] < 3) {
					args[1] = 20
					set_hudmessage(255, 69, 0, -1.0, 0.25, 0, 0.25, 3.0, 0.0, 0.0, 84)
					show_hudmessage(0, "[Omega Sheron] %L", LANG_PLAYER, "OMEGA_SHERON_TRANSFORM_3", g_playername[id])
					emit_sound(id, CHAN_STATIC, "db_mod_15/omega_powerup3.wav", 0.8, ATTN_NORM, 0, PITCH_NORM) 
					g_power[0][id] = 3
				}
			}
		}
	}
	
	#if defined PLAYER_MODELS
	if(g_transform_mdl_id[id] != g_power[0][id] && g_transform_mdl_id[id] != -1)
		model_update(id)
	#endif
	
	if(get_pcvar_num(cvar_powerup_effect) && args[1] > 0)
		set_task(0.2, "powerup_effect", 0, args, 2, "a", 8)
}
#if defined PLAYER_MODELS
public model_update(id)
{
	if(!is_user_valid_alive(id))
		return;

	static one_model
	one_model = false

	if(g_hero_id[id] > 0) {
		switch(g_hero_id[id]) {
			case 1: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", goku_models[g_power[0][id]])
			case 2: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", vegeta_models[g_power[0][id]])
			case 3: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", gohan_models[g_power[0][id]])
			case 4: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", KRILLIN_MODEL), one_model = true
			case 5: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", PICCOLO_MODEL), one_model = true
		}
	}
	else if(g_villain_id[id] > 0) {
		switch(g_villain_id[id]) {
			case 1: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", frieza_models[g_power[0][id]])
			case 2: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", cell_models[g_power[0][id]])
			case 3: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", superbuu_models[g_power[0][id]])
			case 4: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", broly_models[g_power[0][id]])
			case 5: formatex(g_playermodel[id], charsmax(g_playermodel[]), "%s", OMEGASHENRON_MODEL), one_model = true
		}
	}

	static currentmodel[32]; cs_get_user_model(id, currentmodel, charsmax(currentmodel))
	if(!equali(currentmodel, g_playermodel[id]) && g_playermodel[id][0] != 0) {
		cs_set_user_model(id, g_playermodel[id])
		g_transform_mdl_id[id] = one_model ? -1 : g_power[0][id]
	}
}
#endif

// Emit Sound Forward
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(!is_user_valid_connected(id))
		return FMRES_IGNORED;
	
	if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i') {
		if(sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') { // hit
			emit_sound(id, channel, knife_sounds[0], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		if(sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') { // stab
			emit_sound(id, channel, knife_sounds[1], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		else {
			emit_sound(id, channel, knife_sounds[random_num(2, 4)], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}	
	}
	
	// Use power with IN_USE button
	if(equal(sample, "common/wpn_denyselect.wav") && (pev(id, pev_button) & IN_USE))
		use_power(id)
	
	return FMRES_IGNORED;
}

/*===============================================================================
[Power Effect (Fixed Overflow)]
================================================================================*/
public powerup_effect(args[]) {
	static id, origin[3]
	id = args[0]
	
	if(!is_user_valid_alive(id) || !get_pcvar_num(cvar_powerup_effect)) 
		return;

	get_user_origin(id, origin)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE) // TE id
	write_coord(origin[0]+random_num(-5, 5)) // x
	write_coord(origin[1]+random_num(-5, 5)) // y
	write_coord(origin[2]+random_num(-10, 10)) // z
	write_short(spr[1]) // sprite
	write_byte(args[1]) // scale
	write_byte(25) // brightness
	message_end()
}
/*====================================================================
[Knife Model]
=====================================================================*/
public event_CurWeapon(id)
{
	// Not alive...
	if(!is_user_valid_alive(id))
		return PLUGIN_CONTINUE
	
	if(read_data(2) == CSW_KNIFE) {
		entity_set_string(id, EV_SZ_viewmodel, DBZ_KNIFE_V_MODEL)
		entity_set_string(id, EV_SZ_weaponmodel, "")
	}
	else {
		engclient_cmd(id, "weapon_knife")
	}
		
	return PLUGIN_CONTINUE
}

/*===============================================================================
[Load .cfg File]
================================================================================*/
public plugin_cfg() {
	// Load .cfg File
	static configsdir[32], i; get_configsdir(configsdir, charsmax(configsdir))
	server_cmd("exec %s/dragon_ball_mod.cfg", configsdir)
	
	// These cvars are checked very often
	for(i = 0; i <= 4; i++) g_energy_level[i] = get_pcvar_num(cvar_energy_need) * (i+1)
}

/*===============================================================================
[Natives]
================================================================================*/
public native_get_user_energy(id) return g_power[2][id];
public native_set_user_energy(id, amount) g_power[2][id] = amount;
public native_get_user_hero_id(id) return g_hero_id[id];
public native_get_user_villain_id(id) return g_villain_id[id];
public native_get_energy_level(id) return g_power[0][id];
public native_set_energy_level(id, amount) 
{
	if(amount > 5) 
		amount = 5
	
	g_power[0][id] = amount
	g_power[2][id] = amount > 0 ? g_energy_level[amount-1] : 0
	
	#if defined PLAYER_MODELS
	model_update(id)
	#endif
}

/*===============================================================================
[Stocks]
================================================================================*/
// Harm and realize what and who killed
extra_dmg(id, attacker, damage, weaponDescription[]) {
	if(pev(id, pev_takedamage) == DAMAGE_NO || damage <= 0) 
		return;

	if(get_user_health(id) - damage <= 0) {
		set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET);
		ExecuteHamB(Ham_Killed, id, attacker, 2);
		set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT);

		message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"));
		write_byte(attacker);
		write_byte(id);
		write_byte(0);
		write_string(weaponDescription);
		message_end();
		
		set_pev(attacker, pev_frags, float(get_user_frags(attacker) + 1));
		
		static kname[32], vname[32], kauthid[32], vauthid[32], kteam[10], vteam[10];
		get_user_name(attacker, kname, 31); get_user_team(attacker, kteam, 9); get_user_authid(attacker, kauthid, 31);
		get_user_name(id, vname, 31); get_user_team(id, vteam, 9); get_user_authid(id, vauthid, 31);
		
		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", kname, get_user_userid(attacker), kauthid, kteam, 
		vname, get_user_userid(id), vauthid, vteam, weaponDescription);
	}
	else ExecuteHam(Ham_TakeDamage, id, 0, attacker, float(damage), DMG_BLAST);
}

// Fix for the HL engine bug when HP is multiples of 256
public message_health(msg_id, msg_dest, msg_entity) {
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if(health < 256) return;
	
	// Check if we need to fix it
	if(health % 256 == 0)
		set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}
// Print color with replaces
stock client_printcolor(const id, const input[], any:...) {
	static msg[191]; vformat(msg, charsmax(msg), input, 3)
	replace_string(msg, charsmax(msg), "!g", "^4")  // Green Chat
	replace_string(msg, charsmax(msg), "!y", "^1")  // Yellow Chat
	replace_string(msg, charsmax(msg), "!t", "^3")  // Team Color Chat
	client_print_color(id, print_team_default, msg)
}

stock fm_cs_set_user_nobuy(id) {
	if(pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0)) //no weapon buy
}

#if defined PLAYER_MODELS
precache_playermodel(const modelname[]) 
{  
	static longname[128] 
	formatex(longname, charsmax(longname), "models/player/%s/%s.mdl", modelname, modelname)  	
	precache_model(longname)
	
	copy(longname[strlen(longname)-4], charsmax(longname) - (strlen(longname)-4), "T.mdl") 
	if(file_exists(longname)) 
		precache_model(longname)
} 
#endif
