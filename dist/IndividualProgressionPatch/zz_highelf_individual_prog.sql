-- TO BE RUN AFTER INDIVIDUAL PROGRESSION SQL FILES

-- Give High Elves weapon skills to match Human Warrior / Night Elf Hunter
UPDATE `playercreateinfo_skills` SET `racemask` = 2568 WHERE `racemask` = 520 AND `classMask` = 4 AND `skill` = 173; -- Hunter - Daggers
UPDATE `playercreateinfo_skills` SET `racemask` = 3255 WHERE `racemask` = 1207 AND `classMask` = 1 AND `skill` = 44; -- Warrior - Axes
UPDATE `playercreateinfo_skills` SET `racemask` = 3693 WHERE `racemask` = 1645 AND `classMask` = 1 AND `skill` = 54; -- Warrior - Maces
UPDATE `playercreateinfo_skills` SET `racemask` = 3675 WHERE `racemask` = 1627 AND `classMask` = 1 AND `skill` = 43; -- Warrior - Swords

-- Reapply action bars blatted by individual progression 
-- Human Warrior -> High Elf Warrior
INSERT IGNORE INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 1 AND `Class` = 1;
-- Human Paladin -> High Elf Paladin
INSERT IGNORE INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 1 AND `Class` = 2;
-- Night Elf Hunter -> High Elf Hunter
INSERT IGNORE INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 4 AND `Class` = 3;
-- Human Rogue -> High Elf Rogue
INSERT IGNORE INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 1 AND `Class` = 4;
-- Human Priest -> High Elf Priest
INSERT IGNORE INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 1 AND `Class` = 5;
-- Human Death Knight -> High Elf Death Knight
INSERT IGNORE INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 1 AND `Class` = 6;
-- Human Mage -> High Elf Mage
INSERT IGNORE INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 1 AND `Class` = 8;
-- Human Warlock -> High Elf Warlock
INSERT IGNORE INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 1 AND `Class` = 9;