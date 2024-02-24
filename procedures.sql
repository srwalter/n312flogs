DELIMITER //

DROP PROCEDURE IF EXISTS createLogSimple //
CREATE PROCEDURE createLogSimple (endTach DECIMAL(8,2), endHobbs DECIMAL(8,2), startOil DECIMAL(4,2), oilAdded DECIMAL(4,2), note VARCHAR(255), OUT logNumber INT)
SQL SECURITY INVOKER
BEGIN
    DECLARE user VARCHAR(255);
    SET user = CURRENT_USER();
    SET user = CASE
        WHEN user = "srwalter@localhost" THEN "Steven"
        WHEN user = "jim@localhost" THEN "Jim"
        WHEN user = "mike@localhost" THEN "Mike"
        WHEN user = "dan@localhost" THEN "Dan"
        WHEN user = "vickus@localhost" THEN "Vickus"
    END;
    CALL createLog(user, NOW(), endTach, endHobbs, startOil, oilAdded, note, logNumber);
END //

DROP PROCEDURE IF EXISTS createLog //
CREATE PROCEDURE createLog (pilot VARCHAR(255), day DATE, endTach DECIMAL(8,2), endHobbs DECIMAL(8,2), startOil DECIMAL(4,2), oilAdded DECIMAL(4,2), note VARCHAR(255), OUT logNumber INT)
BEGIN
    INSERT INTO logs (pilot, day, endTach, endHobbs, startOil, oilAdded, note)
        VALUES (pilot, day, endTach, endHobbs, startOil, oilAdded, note);
    SET logNumber = LAST_INSERT_ID();
END //

DROP PROCEDURE IF EXISTS modifyLog //
CREATE PROCEDURE modifyLog (_entry INT, pilot VARCHAR(255), day DATE, endTach DECIMAL(8,2), endHobbs DECIMAL(8,2), startOil DECIMAL(4,2), oilAdded DECIMAL(4,2), note VARCHAR(255), OUT result VARCHAR(255))
BEGIN
    UPDATE logs as l SET
        l.pilot = pilot,
        l.day = day,
        l.endTach = endTach,
        l.endHobbs = endHobbs,
        l.startOil = startOil,
        l.oiladded = oilAdded,
        l.note = note
        WHERE l.entry = _entry;
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS deleteLog //
CREATE PROCEDURE deleteLog (_entry INT, OUT result VARCHAR(255))
BEGIN
    DELETE FROM logs WHERE logs.entry = _entry;
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS listLogs //
CREATE PROCEDURE listLogs (paginate_count INT, paginate_offset INT, OUT paginate_total INT)
BEGIN
	SELECT *
            FROM logs ORDER BY day
            LIMIT paginate_count
            OFFSET paginate_offset;
        SELECT COUNT(*) INTO paginate_total FROM logs;
END //

DROP PROCEDURE IF EXISTS listRoles //
CREATE PROCEDURE listRoles ()
BEGIN
	SELECT 'logs_normalUser', 'Normal';
END //

CREATE ROLE IF NOT EXISTS logs_normalUser;

GRANT EXECUTE ON PROCEDURE createLogSimple TO acct_normalUser;
GRANT EXECUTE ON PROCEDURE listLogs TO acct_normalUser;
