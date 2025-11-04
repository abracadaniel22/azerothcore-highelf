-- ===================================--
-- ===================================--
-- World DB - after server initialized for the first time
-- This can be run with sudo mysql acore_characters < highelf_post_install.sql
-- DONT FORGET TO RESTART SERVER sudo service ac-worldserver restart
-- @ author abracadaniel22
-- ===================================--
-- ===================================--

-- -----------
-- Update playerbots names to give half of the blood elf names to high elves
-- TODO: this is NOT IDEMPOTENT
-- -----------

-- Move half (2500) of the available names from blood elf male to high elf male
SET @input_gender = 16;
SET @new_gender = 18;

SELECT COUNT(*) INTO @total_rows
FROM playerbots_names
WHERE gender = @input_gender;

SET @half_count = FLOOR(@total_rows / 2);

SET @sql = CONCAT('
    WITH random_rows AS (
        SELECT name_id
        FROM playerbots_names
        WHERE gender = ', @input_gender, '
        ORDER BY RAND()
        LIMIT ', @half_count, '
    )
    UPDATE playerbots_names
    JOIN random_rows USING (name_id)
    SET gender = ', @new_gender, ';
');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Move half (2500) of the available names from blood elf felame to high elf female
SET @input_gender = 17;
SET @new_gender = 19;

SELECT COUNT(*) INTO @total_rows
FROM playerbots_names
WHERE gender = @input_gender;

SET @half_count = FLOOR(@total_rows / 2);

SET @sql = CONCAT('
    WITH random_rows AS (
        SELECT name_id
        FROM playerbots_names
        WHERE gender = ', @input_gender, '
        ORDER BY RAND()
        LIMIT ', @half_count, '
    )
    UPDATE playerbots_names
    JOIN random_rows USING (name_id)
    SET gender = ', @new_gender, ';
');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
