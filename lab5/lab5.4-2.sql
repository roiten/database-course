USE path;

BEGIN;
UPDATE directories
SET name = 'newdir' WHERE id = 5;

UPDATE directories
SET name = 'folder' WHERE id = 2;

ROLLBACK;