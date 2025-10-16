-- ===================================--
-- ===================================--
-- World DB - after server initialized for the first time
-- This can be run with sudo mysql acore_world < highelf_post_install.sql
-- DONT FORGET TO RESTART SERVER sudo service ac-worldserver restart
-- KEEP THIS FILE IDEMPOTENT
-- @ author abracadaniel22
-- ===================================--
-- ===================================--

-- Player main race stats
INSERT INTO player_race_stats (
  Race, Strength, Agility, Stamina, Intellect, Spirit
)
SELECT
  12, Strength, Agility, Stamina, Intellect, Spirit
FROM player_race_stats AS src
WHERE src.Race = 10
  AND NOT EXISTS (
    SELECT 1 FROM player_race_stats WHERE Race = 12
  ); -- -3,2,0,3,-2 as of 2025


-- starting zone for new high elves (all classes, except DK (6), go to human starting zone)
-- overly-complicated idempotent insert. you're welcome.
INSERT INTO acore_world.playercreateinfo (race,class,`map`,`zone`,position_x,position_y,position_z,orientation)
SELECT * FROM (
    SELECT 12 AS race, 1 AS class, 0 AS `map`, 12 AS `zone`, -8949.95 AS position_x, -132.493 AS position_y, 83.5312 AS position_z, 0.0 AS orientation UNION ALL
	 SELECT 12,2,0,12,-8949.95,-132.493,83.5312,0.0 UNION ALL
	 SELECT 12,3,0,12,-8949.95,-132.493,83.5312,0.0 UNION ALL
	 SELECT 12,4,0,12,-8949.95,-132.493,83.5312,0.0 UNION ALL
	 SELECT 12,5,0,12,-8949.95,-132.493,83.5312,0.0 UNION ALL
	 SELECT 12,6,609,4298,2355.84,-5664.77,426.028,3.65997 UNION ALL
	 SELECT 12,8,0,12,-8949.95,-132.493,83.5312,0.0 UNION ALL
	 SELECT 12,9,0,12,-8949.95,-132.493,83.5312,0.0
) AS tmp
WHERE NOT EXISTS (
    SELECT 1 FROM acore_world.playercreateinfo WHERE race = 12
);

-- Actions put in the toolbar for new players. Just copy from Blood elves
INSERT INTO acore_world.playercreateinfo_action  (
   race, class, button, action, type
)
SELECT
  12, class, button, action, type
FROM acore_world.playercreateinfo_action
WHERE race = 10
  AND NOT EXISTS (
    SELECT 1 FROM acore_world.playercreateinfo_action WHERE Race = 12
  );

-- However, blood elves dont have all classes high elves can be, so 
-- manually copy Warrior from humans
-- There's no implementation of arcane torrent for warrior 3.3.5a, so they don't get arcane torrent. No big deal.
-- Retail warrior arcane torrent: https://www.wowhead.com/spell=69179/arcane-torrent
-- Fixing this is definitely doable, a new spell definition (DBC) and a spell_script (DB) to implement it

INSERT INTO acore_world.playercreateinfo_action  (
   race, class, button, action, type
)
SELECT
  12, class, button, action, type
FROM acore_world.playercreateinfo_action
WHERE race = 1 and class = 1
  AND NOT EXISTS (
    SELECT 1 FROM acore_world.playercreateinfo_action WHERE Race = 12
  );


update acore_world.playercreateinfo_skills  set racemask = 2560 where racemask=512 and skill = 756; 

-- Language: Thalassian
update acore_world.playercreateinfo_skills  set racemask = 2560 where racemask=512 and skill = 137; 
	 	 
-- Bows
update acore_world.playercreateinfo_skills  set racemask = 2698 where racemask=650 and skill = 45; 

-- Daggers
update acore_world.playercreateinfo_skills  set racemask = 2783 where racemask=735 and skill = 173; 

-- Two handed maces
update acore_world.playercreateinfo_skills  set racemask = 3109 where racemask=1061 and skill = 160; 

-- This only affects language: Common
update acore_world.playercreateinfo_skills  set racemask = 3149 where racemask = 1101;


-- Update playerbots table that has race. This doesn't seem to be used though
INSERT INTO acore_world.playerbots_rpg_races  (
   id, entry, race, minl, maxl
)
SELECT
  null, entry, 12, minl, maxl
FROM acore_world.playerbots_rpg_races
WHERE race = 1
  AND NOT EXISTS (
    SELECT 1 FROM acore_world.playerbots_rpg_races WHERE race = 12
  );


-- Allow Human-exclusive NPC gossip windows to appear for High Elf (contribution by Dasbadman)
-- Among other things, this allows High Elves to buy mounts in Elwynn
DELETE FROM `conditions` WHERE SourceGroup IN (4004, 4018) AND ConditionTypeOrReference = 16;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(14, 4004, 4859, 0, 0, 16, 0, 2049, 0, 0, 0, 0, 0, '', 'NPC Text - Show text if Player is Human or High Elf'),
(14, 4004, 5855, 0, 0, 16, 0, 2049, 0, 0, 1, 0, 0, '', 'NPC Text - Show text if Player is Human or High Elf'),
(14, 4018, 4876, 0, 0, 16, 0, 2049, 0, 0, 0, 0, 0, '', 'Show gossip text if player is a Human or High Elf'),
(14, 4018, 5861, 0, 0, 16, 0, 1790, 0, 0, 0, 0, 0, '', 'Show gossip text if player is not a Human or High Elf'),
(15, 4004, 0, 0, 0, 16, 0, 2049, 0, 0, 0, 0, 0, '', 'Gossip Option - Show Option if Player is Human or High Elf'),
(15, 4018, 0, 0, 0, 16, 0, 12049, 0, 0, 0, 0, 0, '', 'Show gossip option if player is a Human or High Elf');


-- Allow high elves to take quests
-- This was generated automatically with a python script
-- If the last bit (human) was active, then set the 12th bit (high elf)

UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 15;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 16;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 17;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 18;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 19;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 20;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 21;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 22;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 33;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 34;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 35;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 36;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 37;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 38;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 39;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 40;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 45;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 46;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 47;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 48;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 49;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 50;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 51;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 52;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 53;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 54;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 56;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 57;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 58;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 59;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 60;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 61;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 62;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 64;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 65;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 66;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 67;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 68;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 69;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 70;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 71;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 72;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 74;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 75;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 76;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 78;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 79;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 80;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 83;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 84;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 85;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 86;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 87;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 88;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 89;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 90;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 91;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 92;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 93;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 94;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 95;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 97;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 98;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 101;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 102;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 106;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 107;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 109;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 111;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 112;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 114;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 115;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 116;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 117;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 120;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 121;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 123;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 125;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 127;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 128;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 129;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 130;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 131;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 132;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 133;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 134;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 135;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 141;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 142;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 143;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 144;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 145;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 146;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 147;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 148;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 149;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 150;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 151;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 153;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 154;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 155;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 156;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 157;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 158;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 159;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 160;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 161;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 162;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 163;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 164;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 165;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 166;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 167;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 168;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 169;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 170;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 171;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 173;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 174;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 175;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 176;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 177;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 178;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 179;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 180;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 181;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 182;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 183;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 184;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 198;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 199;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 200;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 202;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 203;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 204;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 205;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 206;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 207;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 210;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 211;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 212;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 214;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 215;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 217;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 218;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 219;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 221;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 222;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 224;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 225;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 226;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 227;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 229;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 230;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 231;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 233;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 234;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 236;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 237;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 239;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 240;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 244;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 245;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 246;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 248;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 249;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 250;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 251;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 252;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 253;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 255;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 256;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 257;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 258;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 261;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 262;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 263;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 265;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 266;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 267;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 268;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 269;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 270;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 271;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 273;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 274;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 275;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 276;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 277;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 278;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 279;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 280;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 281;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 283;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 284;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 285;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 286;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 287;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 288;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 289;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 290;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 291;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 292;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 293;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 294;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 295;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 296;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 297;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 298;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 299;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 301;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 302;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 303;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 304;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 305;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 306;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 307;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 308;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 309;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 310;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 311;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 312;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 313;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 314;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 315;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 317;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 318;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 319;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 320;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 323;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 324;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 328;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 329;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 330;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 331;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 332;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 333;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 334;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 335;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 336;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 337;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 343;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 344;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 345;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 346;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 347;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 350;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 353;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 373;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 377;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 378;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 384;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 385;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 386;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 387;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 388;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 389;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 391;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 392;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 393;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 394;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 395;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 396;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 397;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 399;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 400;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 401;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 412;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 413;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 414;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 415;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 416;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 417;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 418;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 419;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 420;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 432;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 433;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 434;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 436;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 453;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 454;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 455;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 463;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 464;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 465;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 466;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 467;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 468;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 469;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 471;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 473;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 474;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 475;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 484;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 500;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 504;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 505;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 510;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 511;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 512;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 514;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 522;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 523;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 525;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 526;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 531;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 536;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 537;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 538;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 540;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 542;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 543;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 551;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 554;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 555;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 559;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 560;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 562;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 563;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 564;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 565;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 574;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 578;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 579;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 601;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 602;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 603;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 610;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 611;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 614;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 615;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 616;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 618;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 622;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 623;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 627;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 631;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 632;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 633;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 634;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 637;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 647;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 653;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 659;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 661;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 682;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 683;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 684;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 685;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 686;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 689;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 690;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 691;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 693;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 694;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 695;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 696;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 697;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 700;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 704;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 706;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 707;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 708;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 717;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 718;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 719;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 720;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 721;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 722;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 723;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 724;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 725;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 726;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 727;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 732;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 733;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 735;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 738;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 739;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 762;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 779;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 783;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 930;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 931;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 939;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 941;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 971;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 976;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 978;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 979;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 990;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 991;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1007;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1008;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1009;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1010;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1011;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1012;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1015;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1016;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1017;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1019;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1020;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1021;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1022;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1023;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1024;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1025;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1026;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1027;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1028;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1029;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1030;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1031;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1032;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1033;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1034;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1035;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1037;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1038;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1039;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1040;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1041;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1042;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1043;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1044;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1045;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1046;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1047;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1050;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1052;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1053;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1054;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1055;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1056;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1057;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1059;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1070;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1071;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1072;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1073;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1074;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1075;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1076;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1077;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1078;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1079;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1080;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1081;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1082;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1083;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1084;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1085;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1091;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1097;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1100;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1101;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1132;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1133;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1134;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1135;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1139;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1142;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1179;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1198;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1199;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1200;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1204;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1219;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1220;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1222;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1241;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1243;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1244;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1245;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1246;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1247;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1248;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1249;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1250;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1252;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1253;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1258;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1259;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1260;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1264;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1265;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1266;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1267;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1271;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1274;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1275;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1282;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1284;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1285;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1286;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1287;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1288;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1289;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1301;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1302;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1319;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1320;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1324;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1338;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1339;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1360;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1363;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1364;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1382;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1384;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1385;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1386;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1387;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1395;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1396;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1398;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1421;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1423;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1425;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1437;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1438;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1439;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1440;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1442;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1447;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1448;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1449;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1450;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1451;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1452;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1453;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1454;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1455;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1456;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1457;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1458;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1459;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1465;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1466;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1467;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1468;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1469;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1475;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1477;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1479;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1558;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1578;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1579;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1580;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1581;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1582;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1598;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1618;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1638;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1639;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1640;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1641;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1642;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1643;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1644;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1649;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1650;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1651;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1652;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1653;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1654;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1655;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1658;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1661;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1665;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1666;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1667;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1680;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1681;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1682;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1683;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1684;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1685;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1686;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1687;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1688;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1689;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1692;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1693;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1698;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1699;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1700;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1701;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1702;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1705;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1706;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1708;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1709;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1710;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1711;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1715;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1716;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1717;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1738;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1739;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1758;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1780;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1781;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1782;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1786;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1787;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1788;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1790;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1793;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1794;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1798;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1802;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1804;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1806;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1860;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 1861;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1879;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1880;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1919;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1920;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1921;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1938;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1939;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1940;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1941;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 1942;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2038;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2039;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2040;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2041;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2158;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2159;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2160;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2198;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2199;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2200;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2201;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2204;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2205;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2206;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2218;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2238;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2239;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2240;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2241;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2242;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2259;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2260;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2279;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2281;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2282;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2298;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2299;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2300;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2359;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2360;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2361;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2398;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2439;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2500;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2501;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2518;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2519;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2520;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2607;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2608;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2609;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2745;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2746;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2758;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2759;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2769;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2783;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2821;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2844;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2845;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2847;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2848;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2849;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2850;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2851;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2852;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2853;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2866;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2867;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2869;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2870;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2871;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2877;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2879;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2922;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2923;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2924;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2925;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2926;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2927;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2928;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2929;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2930;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2931;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2939;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2940;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2941;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2942;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2943;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2944;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2946;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2947;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2948;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2962;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2963;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2964;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2969;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2970;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2972;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2977;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2982;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2988;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2989;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2990;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2991;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2992;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2993;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 2994;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 2998;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3022;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 3100;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 3101;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 3102;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 3103;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 3104;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 3105;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3116;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3117;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3118;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3119;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3120;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3130;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3181;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3182;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3201;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3361;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3364;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3365;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3367;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3368;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3370;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3371;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3372;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3377;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3378;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3445;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3448;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3449;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3450;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3451;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3461;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3483;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 3512;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3566;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3629;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3630;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3632;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3634;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3636;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3640;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3641;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3661;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 3681;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3701;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3702;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3763;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3764;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3765;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3781;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3785;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3788;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3789;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3790;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3791;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3792;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3803;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3823;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3824;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3825;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3841;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3842;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3843;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3903;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3904;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 3905;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4101;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4103;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4104;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4105;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4106;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4107;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4108;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4109;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4110;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4111;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4112;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4124;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4125;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4126;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4127;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4128;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4129;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4130;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4131;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4135;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4141;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4142;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4143;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4144;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4181;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4182;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4183;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4184;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4185;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4186;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4223;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4224;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4241;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4242;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4261;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4262;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4263;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4264;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4265;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4266;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4267;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4281;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4282;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4283;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4286;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4297;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4298;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4322;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4341;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4342;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4361;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4362;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4363;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4421;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4441;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4442;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4485;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4486;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4487;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4488;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4508;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4510;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4512;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4513;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4581;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4722;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4723;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4725;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4727;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4728;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4730;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4731;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4732;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4733;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4736;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4738;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4764;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4765;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4766;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4811;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4812;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4822;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4861;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4863;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4864;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4901;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4902;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4906;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4965;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4967;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4970;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 4986;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5001;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5022;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5048;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5066;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5081;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5089;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5090;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5091;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5092;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5097;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5102;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5141;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5143;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5144;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5201;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5215;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5216;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5217;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5219;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5220;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5222;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5223;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5225;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5226;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5237;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5244;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5245;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5246;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5247;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5248;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5249;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5250;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5252;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5253;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5261;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5283;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5284;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5343;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5344;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5401;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5404;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5407;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5408;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5505;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5533;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5537;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5538;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5541;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5545;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5623;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5624;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5625;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5626;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2053 WHERE ID = 5634;/*old mask: 5*/
UPDATE quest_template SET AllowableRaces = 2053 WHERE ID = 5635;/*old mask: 5*/
UPDATE quest_template SET AllowableRaces = 2053 WHERE ID = 5636;/*old mask: 5*/
UPDATE quest_template SET AllowableRaces = 2053 WHERE ID = 5637;/*old mask: 5*/
UPDATE quest_template SET AllowableRaces = 2053 WHERE ID = 5638;/*old mask: 5*/
UPDATE quest_template SET AllowableRaces = 2053 WHERE ID = 5639;/*old mask: 5*/
UPDATE quest_template SET AllowableRaces = 2053 WHERE ID = 5640;/*old mask: 5*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 5676;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 5677;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 5678;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5801;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5803;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 5805;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5841;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5892;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5903;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5904;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 5981;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6028;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6121;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6122;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6123;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6124;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6125;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6141;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6181;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6182;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6183;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6184;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6185;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6186;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6187;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6241;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6261;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6281;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6285;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6389;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6402;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6403;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6501;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6502;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6604;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6609;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6612;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6624;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6625;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6661;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6662;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6761;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6762;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6781;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6846;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6848;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6862;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6881;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6941;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6942;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6943;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 6982;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7022;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7023;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7025;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7026;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7027;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7041;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7042;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7043;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7045;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7062;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7063;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7065;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7070;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7081;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7102;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7121;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7122;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7141;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7162;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7168;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7169;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7170;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7171;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7172;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7202;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7223;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7261;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7282;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7301;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7342;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7364;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7365;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7366;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7367;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7382;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7386;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7424;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7425;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7462;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7482;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7488;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7494;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7495;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7496;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7497;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7562;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7563;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7564;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7623;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7624;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7625;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7626;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7627;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7628;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7629;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7630;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 2643 WHERE ID = 7631;/*old mask: 595*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7637;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7638;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7639;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7640;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7641;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7642;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7643;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7644;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7645;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7646;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7647;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7648;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7666;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3077 WHERE ID = 7670;/*old mask: 1029*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7733;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7735;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7781;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7782;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7788;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7791;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7792;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7793;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7794;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7795;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7796;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7798;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7799;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7800;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7801;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7802;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7803;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7804;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7805;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7806;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7807;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7808;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7809;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7811;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7812;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7848;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7863;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7864;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7865;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7871;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7872;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7873;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7886;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7887;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7888;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7905;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 7921;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8080;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8081;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8105;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8114;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8115;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8154;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8155;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8156;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8157;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8158;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8159;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8166;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8167;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8168;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8260;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8261;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8262;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8268;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8269;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8275;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8291;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8292;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8297;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8298;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8371;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8372;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8374;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8375;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8383;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8384;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8385;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8386;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8391;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8392;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8393;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8394;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8395;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8396;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8397;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8398;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8399;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8400;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8401;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8402;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8403;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8404;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8405;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8406;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8407;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8408;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8414;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8415;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8416;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8418;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8484;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8500;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8504;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8506;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8507;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8508;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8510;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8527;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8762;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8763;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8778;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8780;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8781;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8811;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8812;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8813;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8814;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8819;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8820;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8821;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8822;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8827;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8830;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8831;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8834;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8835;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8836;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8837;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8838;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8839;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8846;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8847;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8848;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8849;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8850;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8860;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8870;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8871;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8872;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8897;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8898;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8899;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8903;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8905;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8906;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8907;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8908;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8909;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8910;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8911;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8912;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8922;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8926;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8929;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8931;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8932;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8933;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8934;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8935;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8936;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8937;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8951;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8952;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8953;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8954;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8955;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8956;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8958;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8959;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8960;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8977;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8997;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 8999;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9000;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9001;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9002;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9003;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9004;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9005;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9006;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9024;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9025;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9026;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9027;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9028;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9260;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9292;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9293;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9294;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9303;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9305;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9309;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9311;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9312;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9313;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9314;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9324;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9325;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9326;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9355;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9365;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9367;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2125 WHERE ID = 9369;/*old mask: 77*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9371;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9383;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9385;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9390;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9398;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9399;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9415;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9417;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9419;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9420;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9423;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9424;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9426;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9427;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9430;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9435;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9446;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9449;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9450;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9451;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9452;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9453;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9454;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9455;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9456;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9462;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9464;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9465;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9467;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9468;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9469;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9471;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9474;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9475;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9476;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9490;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9492;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9493;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9494;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9506;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9512;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9513;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9514;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9515;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9516;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9517;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9518;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9519;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9520;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9521;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9522;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9523;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9526;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9527;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9528;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9530;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9531;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9533;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9537;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9538;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9539;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9540;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9541;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9542;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9543;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9544;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9545;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9548;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9549;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9550;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9555;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9557;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9558;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9559;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9560;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9561;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9562;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9563;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9564;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9565;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9566;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9567;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9569;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9570;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9571;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9573;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9574;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9575;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9576;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9578;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9579;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9580;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9581;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9582;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9584;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9585;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9586;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9587;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9589;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9594;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9595;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9602;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9607;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9609;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9610;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9616;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9620;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9622;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9623;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9624;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9625;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9628;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9629;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9632;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9633;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9634;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9636;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9641;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9642;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9643;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9646;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9647;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9648;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9649;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9663;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9664;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9666;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9667;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9668;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9669;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9670;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9671;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9672;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9674;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9682;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9683;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9687;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9688;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9689;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9693;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9694;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9696;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9698;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9699;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9700;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9703;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9706;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9711;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9740;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9741;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9746;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9748;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9751;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9779;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9780;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9791;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9792;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9794;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9798;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9799;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9827;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9834;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9835;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9839;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9848;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9869;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9871;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9873;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9874;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9879;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9901;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9917;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9918;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9920;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9921;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9922;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9923;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9924;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9933;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9936;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9938;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9940;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9954;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9955;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9961;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9982;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9986;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9992;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9994;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9996;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 9998;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10002;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10005;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10007;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10012;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10016;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10022;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10026;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10028;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10033;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10035;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10038;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10040;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10042;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10047;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10050;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10051;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10055;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10057;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10058;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10063;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10064;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10065;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10066;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10067;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10078;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10079;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10093;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10099;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10106;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10108;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10113;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10116;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10119;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10139;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10140;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10141;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10142;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10143;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10144;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10146;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10160;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10163;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10254;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 10279;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10288;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10302;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10303;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10324;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10340;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10344;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10346;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10350;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10352;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10354;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10356;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10357;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10358;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10373;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10382;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10394;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10395;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10396;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10397;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10399;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10400;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10404;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10428;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10443;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10444;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10446;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10455;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10456;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10457;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10476;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10477;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10482;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10483;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10484;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10485;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10492;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10494;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10496;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10498;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10501;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10502;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10504;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10506;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10510;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10511;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10512;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10516;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10517;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10518;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10520;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10555;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10556;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10557;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10562;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10563;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10564;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10569;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10572;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10573;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10580;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10581;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10582;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10583;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10584;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10585;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10586;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10589;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10594;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10606;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10608;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10609;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10612;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10620;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10621;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10626;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10632;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10642;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10643;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10644;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10645;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10648;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10657;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10661;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10662;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10671;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10674;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10675;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10677;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10678;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10680;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10690;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10695;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10696;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10699;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10700;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10703;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10710;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10711;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10712;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10744;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10752;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10754;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10759;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10762;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10763;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10764;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10766;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10772;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10773;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10774;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10775;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10776;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10795;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10796;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10797;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10798;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10799;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10800;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10801;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10802;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10803;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10805;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10806;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10818;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10863;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10869;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10891;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10895;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10903;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10909;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10916;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10919;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10927;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10935;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10936;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10937;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10943;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10956;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10962;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 10968;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11002;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11040;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11042;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11043;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11044;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11045;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11053;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11054;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11055;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11075;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11076;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11084;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11092;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11098;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 11107;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11117;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11118;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11122;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11123;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11126;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11128;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11131;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11133;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11134;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11136;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11137;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11138;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11139;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11140;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11141;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11142;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11143;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11144;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11145;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11146;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11147;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11148;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11149;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11150;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11151;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11152;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11153;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11154;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11155;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11157;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11175;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11176;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11177;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11185;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11187;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11188;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11190;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11191;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11192;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11193;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11194;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11198;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11199;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11202;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11209;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11210;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11212;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11214;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11218;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11222;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11223;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11224;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11228;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11231;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11235;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11236;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11237;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11238;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11239;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11240;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11243;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11244;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11245;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11246;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11247;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11248;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11249;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11250;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11251;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11252;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11255;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11269;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11273;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11274;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11276;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11277;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11278;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11284;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11288;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11289;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11290;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11291;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11292;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11293;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11294;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11299;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11300;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11302;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11318;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11321;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11322;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11325;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11326;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11327;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11328;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11329;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11330;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11331;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11332;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11333;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11335;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11336;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11337;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11338;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11343;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11344;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11346;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11348;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11349;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11355;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11358;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11359;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11390;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11391;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11393;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11394;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11395;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11396;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11400;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11406;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11410;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11414;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11416;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11418;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11420;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11421;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11426;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11427;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11429;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11430;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11432;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11436;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11441;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11442;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11443;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11448;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11452;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11460;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11465;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11468;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11470;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11474;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11475;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11477;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11478;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11483;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11484;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11485;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11486;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11489;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11491;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11494;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11495;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11497;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11501;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11502;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11505;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11573;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11575;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11580;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11583;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11599;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11600;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11601;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11603;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11604;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11645;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11650;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11653;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11658;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11670;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11672;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11673;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11692;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11693;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11694;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11697;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11698;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11699;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11700;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11701;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11704;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11707;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11708;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11710;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11712;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11713;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11715;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11718;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11723;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11725;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11726;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11727;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11728;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11729;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11730;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11731;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11764;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11765;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11766;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11767;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11768;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11769;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11770;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11771;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11772;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11773;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11774;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11775;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11776;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11777;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11778;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11779;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11780;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11781;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11782;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11783;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11784;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11785;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11786;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11787;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11788;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11789;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11790;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11791;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11792;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11793;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11794;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11795;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11796;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11797;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11798;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11799;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11800;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11801;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11802;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11803;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11804;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11805;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11806;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11807;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11808;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11809;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11810;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11811;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11812;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11813;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11814;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11815;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11816;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11817;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11818;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11819;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11820;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11821;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11822;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11823;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11824;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11825;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11826;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11827;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11828;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11829;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11830;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11831;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11832;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11833;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11834;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11873;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11882;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11889;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11897;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11901;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11902;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11903;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11904;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11908;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11913;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11920;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11927;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11928;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11932;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11935;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11938;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11942;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11944;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11956;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11962;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11963;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11964;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11965;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11970;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11986;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11988;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11993;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11995;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 11998;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12000;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12002;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12003;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12004;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12010;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12014;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12019;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12020;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12022;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12027;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12035;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12055;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12060;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12065;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12067;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12083;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12086;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12088;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12092;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12098;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12105;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12107;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12109;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12119;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12123;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12128;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12129;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12130;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12131;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12133;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12135;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12138;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12141;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12142;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12143;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12146;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12153;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12154;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12157;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12158;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12159;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12160;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12161;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12166;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12167;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12168;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12169;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12171;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12172;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12174;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12180;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12183;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12184;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12185;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12193;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12210;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12212;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12215;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12216;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12217;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12219;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12220;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12222;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12223;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12225;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12226;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12227;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12235;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12237;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12244;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12246;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12247;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12248;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12249;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12250;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12251;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12253;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12255;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12258;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12268;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12269;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12272;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12275;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12276;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12277;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12278;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12281;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12282;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12286;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12287;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12289;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12290;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12291;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12292;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12293;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12294;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12295;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12296;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12297;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12298;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12299;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12300;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12301;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12302;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12305;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12307;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12308;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12309;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12310;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12311;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12312;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12314;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12316;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12319;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12320;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12321;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12323;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12325;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12326;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12331;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12332;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12333;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12334;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12335;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12336;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12337;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12338;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12339;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12340;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12341;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12342;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12343;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12344;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12345;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12346;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12347;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12348;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12349;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12350;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12351;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12352;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12353;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12354;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12355;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12356;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12357;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12358;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12359;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12360;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12414;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12416;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12417;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12418;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12420;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12437;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12438;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12439;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12440;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12441;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12442;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12443;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12444;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12446;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12455;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12457;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12460;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12462;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12463;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12464;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12465;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12466;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12467;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12472;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12473;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12474;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12475;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12476;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12477;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12478;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12491;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12495;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12499;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12511;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3839 WHERE ID = 12652;/*old mask: 1791*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 12742;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12766;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12768;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12770;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 12774;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 12775;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12794;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12817;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12854;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12855;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12858;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12860;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12862;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12863;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12864;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12865;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12866;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12867;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12868;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12869;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12870;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12871;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12872;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12873;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12874;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12875;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12876;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12877;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12878;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12879;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12880;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12881;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12885;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12887;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12896;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12898;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12918;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12973;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 12986;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13004;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13087;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13088;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13094;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13100;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13101;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13102;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13103;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13107;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13153;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13154;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13156;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13177;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13179;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13181;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13186;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13188;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13195;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13196;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13197;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13198;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13205;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13221;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13222;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13225;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13226;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13231;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13232;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13233;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13280;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13284;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13286;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13287;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13288;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13289;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13290;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13291;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13292;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13294;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13295;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13296;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13297;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13298;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13300;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13309;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13314;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13315;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13317;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13318;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13319;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13320;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13321;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13322;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13323;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13332;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13333;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13334;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13335;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13336;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13337;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13338;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13339;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13341;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13342;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13344;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13345;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13346;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13347;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13350;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13369;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13370;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13371;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13377;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13380;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13381;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13382;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13383;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13386;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13387;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13388;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13389;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13390;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13391;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13392;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13393;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13394;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13395;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13396;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13397;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13398;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13399;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13400;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13401;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13402;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13403;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13404;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13405;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13408;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13410;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13415;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13418;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13427;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13441;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13450;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13451;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13453;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13454;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13455;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13457;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13458;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13478;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13480;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13482;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13484;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13485;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13486;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13487;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13488;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13489;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13490;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13491;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13492;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13502;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13524;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13592;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13593;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13600;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13603;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13616;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13625;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13633;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13665;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13666;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13667;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13669;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13670;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13671;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13672;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13679;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13682;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 13684;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13686;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13699;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13700;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 13702;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13703;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13704;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13705;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13706;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13713;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13714;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13715;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13716;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13717;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13718;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13723;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13724;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13725;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13741;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13742;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13743;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13744;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13745;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13746;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13747;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13748;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13749;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13750;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13752;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13753;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13754;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13755;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13756;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13757;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13758;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13759;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13760;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13761;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13788;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13789;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13790;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13791;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13793;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13828;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13835;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13837;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13847;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13851;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13852;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13854;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13855;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13861;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 13864;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 2049 WHERE ID = 13952;/*old mask: 1*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14023;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14024;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14028;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14030;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14033;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14035;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14048;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14051;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14053;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14054;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14055;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14064;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14443;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14444;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 14457;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 20438;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 20439;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24454;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24461;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24476;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24480;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24498;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24499;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24500;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24510;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24522;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24535;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24553;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24595;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24683;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24710;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24711;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24795;/*old mask: 1101*/
UPDATE quest_template SET AllowableRaces = 3149 WHERE ID = 24796;/*old mask: 1101*/




-- Allow high elves to obtain certain items and mounts
-- If humans can have it, high elves also can
UPDATE item_template SET allowablerace = 2559 WHERE entry = 1029;/*name: Tablet of Serpent Totem, old mask: 511*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 1057;/*name: Tablet of Restoration III, old mask: 511*/
UPDATE item_template SET allowablerace = 2463 WHERE entry = 1122;/*name: Deprecated Amulet of the White Stallion, old mask: 415*/
UPDATE item_template SET allowablerace = 2463 WHERE entry = 1123;/*name: Deprecated Amulet of the Pinto, old mask: 415*/
UPDATE item_template SET allowablerace = 2463 WHERE entry = 1124;/*name: Deprecated Amulet of the Palomino, old mask: 415*/
UPDATE item_template SET allowablerace = 2463 WHERE entry = 1125;/*name: Deprecated Amulet of the Nightmare, old mask: 415*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 1133;/*name: Horn of the Winter Wolf, old mask: 223*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 1134;/*name: Horn of the Gray Wolf, old mask: 223*/
UPDATE item_template SET allowablerace = 4095 WHERE entry = 2128;/*name: Scratched Claymore, old mask: 2047*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 2411;/*name: Black Stallion Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 2463 WHERE entry = 2412;/*name: Deprecated Nightmare Bridle, old mask: 415*/
UPDATE item_template SET allowablerace = 2463 WHERE entry = 2413;/*name: Palomino, old mask: 415*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 2414;/*name: Pinto Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 2463 WHERE entry = 2415;/*name: White Stallion, old mask: 415*/
UPDATE item_template SET allowablerace = 4095 WHERE entry = 2484;/*name: Small Knife, old mask: 2047*/
UPDATE item_template SET allowablerace = 4095 WHERE entry = 2502;/*name: Scuffed Dagger, old mask: 2047*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 2556;/*name: Recipe: Elixir of Tongues, old mask: 511*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 3144;/*name: Grimoire of Burning Spirit II, old mask: 511*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 4143;/*name: Tome of Conjure Food II, old mask: 511*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 4273;/*name: Codex of Heal, old mask: 511*/
UPDATE item_template SET allowablerace = 4095 WHERE entry = 5000;/*name: Coral Band, old mask: 2047*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 5150;/*name: Book of Healing Touch III, old mask: 511*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 5655;/*name: Chestnut Mare Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 5656;/*name: Brown Horse Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 5657;/*name: Recipe: Instant Toxin, old mask: 511*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 5660;/*name: Libram: Seal of Righteousness, old mask: 511*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 5663;/*name: Horn of the Red Wolf, old mask: 223*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 5864;/*name: Gray Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 5872;/*name: Brown Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 5873;/*name: White Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 6516;/*name: Imp Summoning Scroll, old mask: 511*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 6544;/*name: Voidwalker Summoning Scroll, old mask: 511*/
UPDATE item_template SET allowablerace = 2559 WHERE entry = 6623;/*name: Succubus Summoning Scroll, old mask: 511*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 8563;/*name: Red Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 8583;/*name: Horn of the Skeletal Mount, old mask: 223*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 8589;/*name: Old Whistle of the Ivory Raptor, old mask: 223*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 8590;/*name: Old Whistle of the Obsidian Raptor, old mask: 223*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 8595;/*name: Blue Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 8627;/*name: Reins of the Night saber, old mask: 223*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 8628;/*name: Reins of the Spotted Nightsaber, old mask: 223*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 8629;/*name: Reins of the Striped Nightsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 8631;/*name: Reins of the Striped Frostsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 8632;/*name: Reins of the Spotted Frostsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 12302;/*name: Reins of the Ancient Frostsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 12303;/*name: Reins of the Nightsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 12353;/*name: White Stallion Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 12354;/*name: Palomino Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 13086;/*name: Reins of the Winterspring Frostsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 13321;/*name: Green Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 13322;/*name: Unpainted Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 13325;/*name: Fluorescent Green Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 13326;/*name: White Mechanostrider Mod B, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 13327;/*name: Icy Blue Mechanostrider Mod A, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 13328;/*name: Black Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 13329;/*name: Frost Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 16338;/*name: Knight-Lieutenant's Steed, old mask: 223*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 16339;/*name: Commander's Steed, old mask: 223*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 16343;/*name: Blood Guard's Mount, old mask: 223*/
UPDATE item_template SET allowablerace = 2271 WHERE entry = 16344;/*name: Lieutenant General's Mount, old mask: 223*/
UPDATE item_template SET allowablerace = 4095 WHERE entry = 17019;/*name: Arcane Dust, old mask: 2047*/
UPDATE item_template SET allowablerace = 4095 WHERE entry = 17027;/*name: Scented Candle, old mask: 2047*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18241;/*name: Black War Steed Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18242;/*name: Reins of the Black War Tiger, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18243;/*name: Black Battlestrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18244;/*name: Black War Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18766;/*name: Reins of the Swift Frostsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18767;/*name: Reins of the Swift Mistsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18772;/*name: Swift Green Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18773;/*name: Swift White Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18774;/*name: Swift Yellow Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18776;/*name: Swift Palomino, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18777;/*name: Swift Brown Steed, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18778;/*name: Swift White Steed, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18785;/*name: Swift White Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18786;/*name: Swift Brown Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18787;/*name: Swift Gray Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 18902;/*name: Reins of the Swift Stormsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 25471;/*name: Ebon Gryphon, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 25472;/*name: Snowy Gryphon, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 25470;/*name: Golden Gryphon, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 25473;/*name: Swift Blue Gryphon, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 25527;/*name: Swift Red Gryphon, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 25528;/*name: Swift Green Gryphon, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 25529;/*name: Swift Purple Gryphon, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 28234;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 28235;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 28236;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 28237;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 28238;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 28481;/*name: Brown Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29227;/*name: Reins of the Cobalt War Talbuk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29229;/*name: Reins of the Silver War Talbuk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29230;/*name: Reins of the Tan War Talbuk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29231;/*name: Reins of the White War Talbuk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29465;/*name: Black Battlestrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29467;/*name: Black War Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29468;/*name: Black War Steed Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29471;/*name: Reins of the Black War Tiger, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29743;/*name: Purple Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29744;/*name: Gray Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29745;/*name: Great Blue Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29746;/*name: Great Green Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 29747;/*name: Great Purple Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 30348;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 30349;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 30350;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 30351;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 31830;/*name: Reins of the Cobalt Riding Talbuk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 31832;/*name: Reins of the Silver Riding Talbuk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 31834;/*name: Reins of the Tan Riding Talbuk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 31836;/*name: Reins of the White Riding Talbuk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 35906;/*name: Reins of the Black War Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 37864;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 40476;/*name: Insignia of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 42123;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 42124;/*name: Medallion of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 43956;/*name: Reins of the Black War Mammoth, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 43958;/*name: Reins of the Ice Mammoth, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 43959;/*name: Reins of the Grand Black War Mammoth, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 43961;/*name: Reins of the Grand Ice Mammoth, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 44098;/*name: Inherited Insignia of the Alliance, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 44223;/*name: Reins of the Black War Bear, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 44225;/*name: Reins of the Armored Brown Bear, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 44230;/*name: Reins of the Wooly Mammoth, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 44235;/*name: Reins of the Traveler's Tundra Mammoth, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 44413;/*name: Mekgineer's Chopper, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 44689;/*name: Armored Snowy Gryphon, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45125;/*name: Stormwind Steed, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45586;/*name: Ironforge Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45589;/*name: Gnomeregan Mechanostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45590;/*name: Exodar Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45591;/*name: Darnassian Nightsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45666;/*name: Ironforge Doublet, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45667;/*name: Stormwind Doublet, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45668;/*name: Exodar Doublet, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45670;/*name: Darnassus Doublet, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 45671;/*name: Gnomeregan Doublet, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46744;/*name: Swift Moonsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46745;/*name: Great Red Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46747;/*name: Turbostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46748;/*name: Swift Violet Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46752;/*name: Swift Gray Steed, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46756;/*name: Great Red Elekk, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46758;/*name: Swift Gray Steed, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46759;/*name: Swift Moonsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46762;/*name: Swift Violet Ram, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46763;/*name: Turbostrider, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46815;/*name: Quel'dorei Steed, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46970;/*name: Drape of the Untamed Predator, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 46971;/*name: Drape of the Untamed Predator, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47089;/*name: Cloak of Displacement, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47095;/*name: Cloak of Displacement, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47100;/*name: Reins of the Striped Dawnsaber, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47105;/*name: The Executioner's Malice, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47110;/*name: The Executioner's Malice, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47149;/*name: Signet of the Traitor King, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47157;/*name: Signet of the Traitor King, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47223;/*name: Ring of the Darkmender, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47224;/*name: Ring of the Darkmender, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47570;/*name: Saronite Swordbreakers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47572;/*name: Titanium Spikeguards, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47574;/*name: Sunforged Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47576;/*name: Crusader's Dragonscale Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47579;/*name: Black Chitin Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47581;/*name: Bracers of Swift Death, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47583;/*name: Moonshadow Armguards, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47585;/*name: Bejeweled Wizard's Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47587;/*name: Royal Moonshroud Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47589;/*name: Titanium Razorplate, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47591;/*name: Breastplate of the White Knight, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47593;/*name: Sunforged Breastplate, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47595;/*name: Crusader's Dragonscale Breastplate, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47597;/*name: Ensorcelled Nerubian Breastplate, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47599;/*name: Knightbane Carapace, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47602;/*name: Lunar Eclipse Robes, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47603;/*name: Merlin's Robe, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47605;/*name: Royal Moonshroud Robe, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47622;/*name: Plans: Breastplate of the White Knight, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47623;/*name: Plans: Saronite Swordbreakers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47624;/*name: Plans: Titanium Razorplate, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47625;/*name: Plans: Titanium Spikeguards, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47626;/*name: Plans: Sunforged Breastplate, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47627;/*name: Plans: Sunforged Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47628;/*name: Pattern: Ensorcelled Nerubian Breastplate, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47629;/*name: Pattern: Black Chitin Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47630;/*name: Pattern: Crusader's Dragonscale Breastplate, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47631;/*name: Pattern: Crusader's Dragonscale Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47632;/*name: Pattern: Lunar Eclipse Robes, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47633;/*name: Pattern: Moonshadow Armguards, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47634;/*name: Pattern: Knightbane Carapace, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47635;/*name: Pattern: Bracers of Swift Death, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47654;/*name: Pattern: Bejeweled Wizard's Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47655;/*name: Pattern: Merlin's Robe, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47656;/*name: Pattern: Royal Moonshroud Bracers, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 47657;/*name: Pattern: Royal Moonshroud Robe, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 49044;/*name: Swift Alliance Steed, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 49096;/*name: Crusader's White Warhorse, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 49289;/*name: Little White Stallion Bridle, old mask: 1101*/
UPDATE item_template SET allowablerace = 3149 WHERE entry = 51377;/*name: Medallion of the Alliance, old mask: 1101*/
