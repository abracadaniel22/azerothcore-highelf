-- TO BE RUN AFTER INDIVIDUAL PROGRESSION SQL FILES

-- Give High Elves weapon skills to match Human Warrior / Night Elf Hunter
UPDATE `playercreateinfo_skills` SET `racemask` = 2568 WHERE `racemask` = 520 AND `classMask` = 4 AND `skill` = 173; -- Hunter - Daggers
UPDATE `playercreateinfo_skills` SET `racemask` = 3255 WHERE `racemask` = 1207 AND `classMask` = 1 AND `skill` = 44; -- Warrior - Axes
UPDATE `playercreateinfo_skills` SET `racemask` = 3693 WHERE `racemask` = 1645 AND `classMask` = 1 AND `skill` = 54; -- Warrior - Maces
UPDATE `playercreateinfo_skills` SET `racemask` = 3675 WHERE `racemask` = 1627 AND `classMask` = 1 AND `skill` = 43; -- Warrior - Swords

-- Reapply Warrior action bar blatted by individual progression 
INSERT INTO `playercreateinfo_action` (
   `Race`, `Class`, `Button`, `Action`, `Type`
)
SELECT
  12, `Class`, `Button`, `Action`, `Type`
FROM `playercreateinfo_action`
WHERE `Race` = 1 AND `Class` = 1
  AND NOT EXISTS (
    SELECT 1 FROM `playercreateinfo_action` WHERE `Race` = 12
  );
-- Correct starting food in action bar for High Elves
UPDATE `playercreateinfo_action` SET `Action` = 2070 WHERE `Race` = 12 AND `Class` = 2 AND `Button` = 11; -- Paladin - Darnassian Bleu
UPDATE `playercreateinfo_action` SET `Action` = 117 WHERE `Race` = 12 AND `Class` = 3 AND `Button` = 11;  -- Hunter  - Tough Jerky
UPDATE `playercreateinfo_action` SET `Action` = 2070 WHERE `Race` = 12 AND `Class` = 4 AND `Button` = 11; -- Rogue   - Darnassian Bleu
UPDATE `playercreateinfo_action` SET `Action` = 2070 WHERE `Race` = 12 AND `Class` = 5 AND `Button` = 11; -- Priest  - Darnassian Bleu
UPDATE `playercreateinfo_action` SET `Action` = 2070 WHERE `Race` = 12 AND `Class` = 8 AND `Button` = 11; -- Mage    - Darnassian Bleu
UPDATE `playercreateinfo_action` SET `Action` = 4604 WHERE `Race` = 12 AND `Class` = 9 AND `Button` = 11; -- Warlock - Forest Mushroom Cap