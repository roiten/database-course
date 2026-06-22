USE path;

BEGIN;
UPDATE directories
SET name = 'sbin' WHERE id = 2;

UPDATE directories
SET name = 'ndir' WHERE id = 5;

ROLLBACK;