USE path;

DROP FUNCTION IF EXISTS GetListByName;

CREATE FUNCTION GetListByName(
    nodeName VARCHAR(255)
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE leafIf INT;
    SELECT d.id
    INTO leafIf
    FROM directories d
             LEFT JOIN directory_closure dc ON d.id = dc.parent_id AND dc.depth > 0
    WHERE dc.parent_id IS NULL
      AND d.name = nodeName;

    RETURN leafIf;
END;

SELECT GetListByName('src');


DROP PROCEDURE IF EXISTS  DeleteSubtreeByName;
CREATE PROCEDURE DeleteSubtreeByName(
    subTreeName VARCHAR(255)
)
BEGIN
    DELETE
    FROM directories
    WHERE name = subTreeName;
END;

DROP VIEW IF EXISTS oopSubTree;

CREATE VIEW oopSubTree AS
SELECT dir.id, dir.name, c.depth
FROM directory_closure c
         JOIN directories dir ON dir.id = c.parent_id
WHERE c.child_id = GetListByName('src')
ORDER BY c.depth, dir.id;

SELECT * FROM oopSubTree;