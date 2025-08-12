-- This file contains queries used to update data in DBC files exported to mysql
-- There is no need to run this if your goal is to just use the mod.
-- @ author abracadaniel22
-- See DBC Creation Step By Step.txt


-- --------------------------------
-- BarberShopStyle
-- Sets up barber shop per race. Without it, barber shop crashes the game.
-- --------------------------------
SET @new_id := (SELECT MAX(ID) FROM db_BarberShopStyle_12340);
insert into db_BarberShopStyle_12340 (
ID, Type, DisplayName_Lang_enUS, DisplayName_Lang_enGB, DisplayName_Lang_koKR, DisplayName_Lang_frFR, DisplayName_Lang_deDE, DisplayName_Lang_enCN, DisplayName_Lang_zhCN, 
DisplayName_Lang_enTW, DisplayName_Lang_zhTW, DisplayName_Lang_esES, DisplayName_Lang_esMX, DisplayName_Lang_ruRU, DisplayName_Lang_ptPT, DisplayName_Lang_ptBR, DisplayName_Lang_itIT, 
DisplayName_Lang_Unk, DisplayName_Lang_Mask, Description_Lang_enUS, Description_Lang_enGB, Description_Lang_koKR, Description_Lang_frFR, Description_Lang_deDE, Description_Lang_enCN, 
Description_Lang_zhCN, Description_Lang_enTW, Description_Lang_zhTW, Description_Lang_esES, Description_Lang_esMX, Description_Lang_ruRU, Description_Lang_ptPT, Description_Lang_ptBR,
Description_Lang_itIT, Description_Lang_Unk, Description_Lang_Mask, Cost_Modifier, Race, Sex, Data
) 
select
@new_id := @new_id + 1, Type, DisplayName_Lang_enUS, DisplayName_Lang_enGB, DisplayName_Lang_koKR, DisplayName_Lang_frFR, DisplayName_Lang_deDE, DisplayName_Lang_enCN, 
DisplayName_Lang_zhCN, DisplayName_Lang_enTW, DisplayName_Lang_zhTW, DisplayName_Lang_esES, DisplayName_Lang_esMX, DisplayName_Lang_ruRU, DisplayName_Lang_ptPT, 
DisplayName_Lang_ptBR, DisplayName_Lang_itIT, DisplayName_Lang_Unk, DisplayName_Lang_Mask, Description_Lang_enUS, Description_Lang_enGB, Description_Lang_koKR, 
Description_Lang_frFR, Description_Lang_deDE, Description_Lang_enCN, Description_Lang_zhCN, Description_Lang_enTW, Description_Lang_zhTW, Description_Lang_esES, 
Description_Lang_esMX, Description_Lang_ruRU, Description_Lang_ptPT, Description_Lang_ptBR, Description_Lang_itIT, Description_Lang_Unk, Description_Lang_Mask, 
Cost_Modifier, 12, Sex, Data
from db_BarberShopStyle_12340
where race=10;


-- --------------------------------
-- CharacterFacialHairStyles
-- All character facial changes, not only hair
-- --------------------------------
-- For this file, use worgoblin's dbc as starting point
-- In order to be compatible with HD patch
-- Non-hd version can use standard dbc
delete from db_CharacterFacialHairStyles_worgob where raceid=12;

SET @new_id := (SELECT MAX(ID) FROM db_CharacterFacialHairStyles_worgob);

INSERT INTO db_CharacterFacialHairStyles_worgob (
  ID, RaceID, SexID, VariationID,
  Geoset_1, Geoset_2, Geoset_3, Geoset_4, Geoset_5
)
SELECT
  @new_id := @new_id + 1, 
  12,
  SexID, VariationID,
  Geoset_1, Geoset_2, Geoset_3, Geoset_4, Geoset_5
FROM db_CharacterFacialHairStyles_worgob
WHERE RaceID = 10;

-- --------------------------------
-- CharBaseInfo
-- Classes by race
-- --------------------------------
-- TODO add queries since it was manually added

-- --------------------------------
-- CharHairGeoSets
-- Hairstyles per race
-- --------------------------------
-- For this file, use worgoblin's dbc as starting point
-- In order to be compatible with HD patch
-- Non-hd version can use standard charsection dbc

delete from db_CharHairGeosets_worg where raceid=12;

SET @new_id := (SELECT MAX(ID) FROM db_CharHairGeosets_worg);
INSERT INTO db_CharHairGeosets_worg (
  ID, RaceID, SexID, VariationID, GeosetID, Showscalp
)
SELECT
  @new_id := @new_id + 1, 12, SexID, VariationID, GeosetID, Showscalp
FROM db_CharHairGeosets_worg
WHERE RaceID = 10;

-- --------------------------------
-- CharSections
-- Character textures for hair, beards, the base skin, etc
-- --------------------------------

-- For this file, use worgoblin's dbc as starting point
-- In order to be compatible with HD patch
-- Non-hd version can use standard charsection dbc

-- Create high elf model entries by copying blood elf model entries
DELETE FROM db_CharSections_12340 WHERE raceid=12;
SET @new_id := (SELECT MAX(ID) FROM db_CharSections_12340);
INSERT INTO db_CharSections_12340 (
ID, 
RaceID, 
SexID, 
BaseSection, 
TextureName_1, 
TextureName_2, 
TextureName_3, 
Flags, 
VariationIndex, 
ColorIndex
)
SELECT
@new_id := @new_id + 1, 
12, 
SexID, 
BaseSection, 
TextureName_1, 
TextureName_2, 
TextureName_3, 
Flags, 
VariationIndex, 
ColorIndex
FROM db_CharSections_12340_worg_no_12
WHERE RaceID = 10;

-- Modify entries 0 to 9 to use the blue eye faceupper models (currently stored in variation 10 to 19)
UPDATE db_CharSections_12340 AS target
JOIN db_CharSections_12340 AS source
  ON target.colorindex = source.colorindex
  AND target.variationindex = source.variationindex - 10
  AND target.raceid = source.raceid
  AND target.sexid = source.sexid
SET
  target.texturename_1 = source.texturename_1,
  target.texturename_2 = source.texturename_2
WHERE target.variationindex < 10
AND target.raceid = 12
AND target.texturename_2 like "%FaceUpper%";


-- --------------------------------
-- CharStartOutfit
-- Starting outfit
-- --------------------------------
-- TODO add query. Copied from Belf id 10

-- --------------------------------
-- ChrRaces
-- Races DB
-- --------------------------------
-- TODO add query. Copied from Belf id 10 with some modifications


-- --------------------------------
-- CreatureDisplayInfo and CreatureDisplayInfoExtra
-- Creature/npc texture models and everything
-- --------------------------------

update db_CreatureDisplayInfoExtra_12340  set DisplayRaceID = 24 where DisplayRaceID = 12;

INSERT INTO db_CreatureDisplayInfoExtra_12340 (
  ID, DisplayRaceID, DisplaySexID, SkinID, FaceID,
  HairStyleID, HairColorID, FacialHairID,
  NPCItemDisplay_1, NPCItemDisplay_2, NPCItemDisplay_3, NPCItemDisplay_4,
  NPCItemDisplay_5, NPCItemDisplay_6, NPCItemDisplay_7, NPCItemDisplay_8,
  NPCItemDisplay_9, NPCItemDisplay_10, NPCItemDisplay_11,
  Flags, BakeName
)
SELECT
  ID + 22000,
  12, -- New DisplayRaceID
  DisplaySexID, SkinID, FaceID,
  HairStyleID, HairColorID, FacialHairID,
  NPCItemDisplay_1, NPCItemDisplay_2, NPCItemDisplay_3, NPCItemDisplay_4,
  NPCItemDisplay_5, NPCItemDisplay_6, NPCItemDisplay_7, NPCItemDisplay_8,
  NPCItemDisplay_9, NPCItemDisplay_10, NPCItemDisplay_11,
  Flags, BakeName
FROM db_CreatureDisplayInfoExtra_12340
WHERE DisplayRaceID = 10;


SET @new_id := (SELECT MAX(ID) FROM db_CreatureDisplayInfo_12340);

INSERT INTO db_CreatureDisplayInfo_12340 (ID, MODELID, SOUNDID, ExtendedDisplayInfoID, CreatureModelScale, CreatureModelAlpha, TextureVariation_1, TextureVariation_2,
TextureVariation_3, PortraitTextureName, BloodLevel, BloodID, NPCSoundID, ParticleColorID, CreatureGeosetData, ObjectEffectPackageID)
select 
@new_id := @new_id + 1, MODELID, SOUNDID, ExtendedDisplayInfoID + 22000, CreatureModelScale, CreatureModelAlpha, TextureVariation_1, TextureVariation_2,
TextureVariation_3, PortraitTextureName, BloodLevel, BloodID, NPCSoundID, ParticleColorID, CreatureGeosetData, ObjectEffectPackageID
FROM db_CreatureDisplayInfo_12340
WHERE ID in (
	select id from db_CreatureDisplayInfo_12340 WHERE ExtendedDisplayInfoID in (
		select ID from db_CreatureDisplayInfoExtra_12340
		WHERE DisplayRaceID = 10
	)
);

-- --------------------------------
-- EmotesTextSound
-- Sound and text of emotes such as /hi . This still doesn't work though
-- --------------------------------

SET @new_id := (SELECT MAX(ID) FROM db_EmotesTextSound_12340);
insert into db_EmotesTextSound_12340 (
ID, EmotesTextID, RaceID, SexID, SoundID
) 
select
@new_id := @new_id + 1, EmotesTextID, 12, SexID, SoundID
from db_EmotesTextSound_12340
where RaceID=10;


-- --------------------------------
-- Faction
-- This control reputations. Without the changes here, character is neutral to both alliance and horde
-- --------------------------------

SET @new_id := (SELECT MAX(ID) FROM db_Faction_12340);
insert into db_Faction_12340 (
ID, ReputationIndex, ReputationRaceMask_1, ReputationRaceMask_2, ReputationRaceMask_3, ReputationRaceMask_4, ReputationClassMask_1, ReputationClassMask_2, ReputationClassMask_3, ReputationClassMask_4, ReputationBase_1, ReputationBase_2, ReputationBase_3, ReputationBase_4, ReputationFlags_1, ReputationFlags_2, ReputationFlags_3, ReputationFlags_4, ParentFactionID, ParentFactionMod_1, ParentFactionMod_2, ParentFactionCap_1, ParentFactionCap_2, Name_Lang_enUS, Name_Lang_enGB, Name_Lang_koKR, Name_Lang_frFR, Name_Lang_deDE, Name_Lang_enCN, Name_Lang_zhCN, Name_Lang_enTW, Name_Lang_zhTW, Name_Lang_esES, Name_Lang_esMX, Name_Lang_ruRU, Name_Lang_ptPT, Name_Lang_ptBR, Name_Lang_itIT, Name_Lang_Unk, Name_Lang_Mask, Description_Lang_enUS, Description_Lang_enGB, Description_Lang_koKR, Description_Lang_frFR, Description_Lang_deDE, Description_Lang_enCN, Description_Lang_zhCN, Description_Lang_enTW, Description_Lang_zhTW, Description_Lang_esES, Description_Lang_esMX, Description_Lang_ruRU, Description_Lang_ptPT, Description_Lang_ptBR, Description_Lang_itIT, Description_Lang_Unk, Description_Lang_Mask
)
select
@new_id := @new_id + 1, ReputationIndex, ReputationRaceMask_1, ReputationRaceMask_2, ReputationRaceMask_3, ReputationRaceMask_4, ReputationClassMask_1, ReputationClassMask_2, ReputationClassMask_3, ReputationClassMask_4, ReputationBase_1, ReputationBase_2, ReputationBase_3, ReputationBase_4, ReputationFlags_1, ReputationFlags_2, ReputationFlags_3, ReputationFlags_4, ParentFactionID, ParentFactionMod_1, ParentFactionMod_2, ParentFactionCap_1, ParentFactionCap_2,
"PLAYER, High Elf", Name_Lang_enGB, Name_Lang_koKR, Name_Lang_frFR, Name_Lang_deDE, Name_Lang_enCN, Name_Lang_zhCN, Name_Lang_enTW, Name_Lang_zhTW, Name_Lang_esES, Name_Lang_esMX, Name_Lang_ruRU, Name_Lang_ptPT, Name_Lang_ptBR, Name_Lang_itIT, Name_Lang_Unk, Name_Lang_Mask, Description_Lang_enUS, Description_Lang_enGB, Description_Lang_koKR, Description_Lang_frFR, Description_Lang_deDE, Description_Lang_enCN, Description_Lang_zhCN, Description_Lang_enTW, Description_Lang_zhTW, Description_Lang_esES, Description_Lang_esMX, Description_Lang_ruRU, Description_Lang_ptPT, Description_Lang_ptBR, Description_Lang_itIT, Description_Lang_Unk, Description_Lang_Mask
from db_Faction_12340
where Name_Lang_enUS = "PLAYER, Human";

UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 21;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 46;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3145 WHERE ID = 47;/*old mask: 1097*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3085 WHERE ID = 54;/*old mask: 1037*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 59;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 67;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 68;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3141 WHERE ID = 69;/*old mask: 1093*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 70;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_3 = 2049 WHERE ID = 72;/*old mask: 1*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 76;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 81;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 83;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 86;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 87;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 92;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 93;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 169;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 270;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 289;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 349;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 369;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 469;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 470;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3145 WHERE ID = 471;/*old mask: 1097*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 509;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 510;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 529;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 530;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 549;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 550;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 551;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 569;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 570;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 571;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 574;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 576;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 577;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 589;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 609;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 729;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 730;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 749;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 809;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 889;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 890;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 891;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 2125 WHERE ID = 892;/*old mask: 77*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 909;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 910;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 911;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 922;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 2125 WHERE ID = 930;/*old mask: 77*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 2303 WHERE ID = 932;/*old mask: 255*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 4095 WHERE ID = 933;/*old mask: 2047*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 2303 WHERE ID = 934;/*old mask: 255*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 935;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 4095 WHERE ID = 936;/*old mask: 2047*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 941;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 4095 WHERE ID = 942;/*old mask: 2047*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 946;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 947;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 4095 WHERE ID = 970;/*old mask: 2047*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 978;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 989;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 990;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1012;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1015;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1031;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 1037;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1038;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 1050;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 1052;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 1064;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 1067;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 1068;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1073;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 1082;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 1085;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3277 WHERE ID = 1090;/*old mask: 1229*/
UPDATE db_Faction_12340 SET ReputationRaceMask_3 = 3149 WHERE ID = 1090;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1091;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 1094;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1104;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1105;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1117;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1118;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3839 WHERE ID = 1119;/*old mask: 1791*/
UPDATE db_Faction_12340 SET ReputationRaceMask_2 = 3149 WHERE ID = 1124;/*old mask: 1101*/
UPDATE db_Faction_12340 SET ReputationRaceMask_1 = 3149 WHERE ID = 1126;/*old mask: 1101*/



-- --------------------------------
-- SkillLineAbility
-- Sets up which spells/skills can be learned, or are learned by default
-- --------------------------------

-- Add high elf to all-alliance skills
UPDATE db_SkillLineAbility_12340 
SET racemask = 3149
where racemask = 1101;

-- Add high elf to human+dwarf+draenei skills
UPDATE db_SkillLineAbility_12340 
SET racemask = 3077
where racemask = 1029;

-- Add high elf to blood elf skills except some that are already above
UPDATE db_SkillLineAbility_12340 
SET racemask = 2560
where racemask = 512
AND spell NOT IN (31898, 53733, 53736, 53742, 34767, 34769, 34767, 34769);

-- --------------------------------
-- SkillRaceClassInfo
-- Skills per race + class
-- --------------------------------

UPDATE db_SkillRaceClassInfo_12340
set racemask = 2215
where skillid = 44 and racemask = 167;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 2560
where racemask = 512;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 2568
where skillid = 173 and racemask = 520;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 2698
where skillid = 45 and racemask = 650;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3071
where skillid = 759 and racemask = 1023;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3077
where skillid = 43 and racemask = 1029;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3111
where skillid = 173 and racemask = 1063;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3149
where racemask = 1101;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3160
where skillid = 44 and racemask = 1112;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3163
where skillid = 43 and racemask = 1115;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3238
where skillid = 173 and racemask = 1190;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3577
where skillid = 172 and racemask = 1529;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3592
where skillid = 44 and racemask = 1544;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 3722
where skillid = 46 and racemask = 1674;

UPDATE db_SkillRaceClassInfo_12340
set racemask = 4095
where racemask = 2047;


-- --------------------------------
-- TalentTab
-- tabs of the talents, which can be seen when opening the talents window in WoW. 
-- --------------------------------
update db_TalentTab_12340 set racemask = 4095 where racemask=2047;


-- --------------------------------
-- VocalUISounds
-- UI error sounds "Can't cast that yet..."
-- --------------------------------

SET @new_id := (SELECT MAX(ID) FROM db_VocalUISounds_12340);
insert into db_VocalUISounds_12340 (
ID, VocalUIEnum, RaceID, NormalSoundID_1, NormalSoundID_2, PissedSoundID_1, PissedSoundID_2
) 
select
@new_id := @new_id + 1, 
VocalUIEnum, 12, NormalSoundID_1, NormalSoundID_2, PissedSoundID_1, PissedSoundID_2
from db_VocalUISounds_12340
where RaceID=10;

-- --------------------------------
-- NameGen
-- Randomize button on character creation
-- --------------------------------
SET @new_id := (SELECT MAX(ID) FROM db_NameGen_12340 );
insert into db_NameGen_12340 (
ID, Name, RaceID, Sex
) 
select
@new_id := @new_id + 1, Name, 12, Sex
from db_NameGen_12340
where RaceID=10;
