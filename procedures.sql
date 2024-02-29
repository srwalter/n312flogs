DELIMITER //

DROP PROCEDURE IF EXISTS lastTimes //
CREATE PROCEDURE lastTimes ()
func: BEGIN
    DECLARE lastHobbs DECIMAL(8,2);
    DECLARE lastTach DECIMAL(8,2);

    SELECT MAX(endTach) AS lastTach, MAX(endHobbs) AS lastHobbs FROM logs;
END;

DROP PROCEDURE IF EXISTS createLogSimple //
CREATE PROCEDURE createLogSimple (endTach DECIMAL(8,2), endHobbs DECIMAL(8,2), startTach DECIMAL(8,2), startHobbs DECIMAL(8,2), departureAirport VARCHAR(16), destinationAirport VARCHAR(16),
    startOil DECIMAL(4,2), oilAdded DECIMAL(4,2), note VARCHAR(255), OUT result VARCHAR(255))
SQL SECURITY INVOKER
func: BEGIN
    DECLARE lastHobbs DECIMAL(8,2);
    DECLARE lastTach DECIMAL(8,2);
    DECLARE user VARCHAR(255);
    DECLARE logNumber INT;

    SELECT MAX(logs.endHobbs) FROM logs INTO lastHobbs;
    SELECT MAX(logs.endTach) FROM logs INTO lastTach;

    IF (startTach IS NULL) THEN
        SET startTach = lastTach;
    END IF;

    IF (startHobbs IS NULL) THEN
        SET startHobbs = lastHobbs;
    END IF;

    IF (startHobbs != lastHobbs) THEN
        SET result = "ERROR:Start hobbs doesn't match last hobbs entry!";
        LEAVE func;
    END IF;

    IF (startTach != lastTach) THEN
        SET result = "ERROR:Start tach doesn't match last tach entry!";
        LEAVE func;
    END IF;

    IF (endHobbs = lastHobbs AND endTach = lastTach) THEN
        SET result = "ERROR:End tach and end hobbs both match last entry!";
        LEAVE func;
    END IF;

    IF (endHobbs < lastHobbs) THEN
        SET result = "ERROR:End hobbs is less than last hobbs!";
        LEAVE func;
    END IF;

    IF (endTach < lastTach) THEN
        SET result = "ERROR:End tach is less than last tach!";
        LEAVE func;
    END IF;

    SET user = CURRENT_USER();
    SET user = CASE
        WHEN user = "srwalter@localhost" THEN "Steven"
        WHEN user = "jim@localhost" THEN "Jim"
        WHEN user = "mike@localhost" THEN "Mike"
        WHEN user = "dan@localhost" THEN "Dan"
        WHEN user = "vickus@localhost" THEN "Vickus"
    END;
    CALL createLog(user, NOW(), endTach, endHobbs, startTach, startHobbs, departureAirport, destinationAirport, startOil, oilAdded, note, logNumber);
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS createLog //
CREATE PROCEDURE createLog (pilot VARCHAR(255), day DATE, endTach DECIMAL(8,2), endHobbs DECIMAL(8,2), startTach DECIMAL(8,2), startHobbs DECIMAL(8,2),
    departureAirport VARCHAR(16), destinationAirport VARCHAR(16), startOil DECIMAL(4,2), oilAdded DECIMAL(4,2), note VARCHAR(255), OUT logNumber INT)
BEGIN
    DECLARE lastHobbs DECIMAL(8,2);
    DECLARE lastTach DECIMAL(8,2);

    SELECT MAX(logs.endHobbs) FROM logs INTO lastHobbs;
    SELECT MAX(logs.endTach) FROM logs INTO lastTach;

    IF (startTach IS NULL) THEN
        SET startTach = lastTach;
    END IF;

    IF (startHobbs IS NULL) THEN
        SET startHobbs = lastHobbs;
    END IF;

    INSERT INTO logs (pilot, day, endTach, endHobbs, startTach, startHobbs, departureAirport, destinationAirport, startOil, oilAdded, note)
        VALUES (pilot, day, endTach, endHobbs, startTach, startHobbs, departureAirport, destinationAirport, startOil, oilAdded, note);
    SET logNumber = LAST_INSERT_ID();
END //

DROP PROCEDURE IF EXISTS modifyLog //
CREATE PROCEDURE modifyLog (_entry INT, pilot VARCHAR(255), day DATE, endTach DECIMAL(8,2), endHobbs DECIMAL(8,2), startTach DECIMAL(8,2), startHobbs DECIMAL(8,2),
    departureAirport VARCHAR(16), destinationAirport VARCHAR(16), startOil DECIMAL(4,2), oilAdded DECIMAL(4,2), note VARCHAR(255), billedDate DATE, OUT result VARCHAR(255))
BEGIN
    UPDATE logs as l SET
        l.pilot = pilot,
        l.day = day,
        l.endTach = endTach,
        l.endHobbs = endHobbs,
        l.startTach = startTach,
        l.startHobbs = startHobbs,
        l.departureAirport = departureAirport,
        l.destinationAirport = destinationAirport,
        l.startOil = startOil,
        l.oiladded = oilAdded,
        l.billedDate = billedDate,
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
	SELECT entry AS _entry, day, pilot, startTach, endTach, endTach - startTach AS tachHours,
        ROUND((endTach - startTach) / (endHobbs - startHobbs) * 100) as tachHobbsPercent, startHobbs, endHobbs, endHobbs - startHobbs AS hobbsHours, departureAirport, destinationAirport, billedDate
            FROM logs ORDER BY endTach DESC
            LIMIT paginate_count
            OFFSET paginate_offset;
        SELECT COUNT(*) INTO paginate_total FROM logs;
END //

DROP PROCEDURE IF EXISTS createHourlyMaint //
CREATE PROCEDURE createHourlyMaint (name VARCHAR(128), frequency DECIMAL(8,2), last DECIMAL(8,2), OUT id INT)
BEGIN
    INSERT INTO hourlyMaint (name, frequency, last)
        VALUES (name, frequency, last);
    SET id = LAST_INSERT_ID();
END //

DROP PROCEDURE IF EXISTS listHourlyMaints //
CREATE PROCEDURE listHourlyMaints (paginate_count INT, paginate_offset INT, OUT paginate_total INT)
BEGIN
	SELECT *
            FROM hourlyMaint ORDER BY name
            LIMIT paginate_count
            OFFSET paginate_offset;
        SELECT COUNT(*) INTO paginate_total FROM hourlyMaint;
END //

DROP PROCEDURE IF EXISTS modifyHourlyMaint //
CREATE PROCEDURE modifyHourlyMaint (_id INT, name VARCHAR(128), frequency DECIMAL(8,2), last DECIMAL(8,2), OUT result VARCHAR(255))
BEGIN
    UPDATE hourlyMaint as h SET
        h.name = name,
        h.frequency = frequency,
        h.last = last
        WHERE h.id = _id;
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS deleteHourlyMaint //
CREATE PROCEDURE deleteHourlyMaint (_id INT, OUT result VARCHAR(255))
BEGIN
    DELETE FROM hourlyMaint WHERE hourlyMaint.id = _id;
    SET result = "Success";
END //


DROP PROCEDURE IF EXISTS createTimedMaint //
CREATE PROCEDURE createTimedMaint (name VARCHAR(128), frequency INT, last DATE, OUT id INT)
BEGIN
    INSERT INTO timedMaint (name, frequency, last)
        VALUES (name, frequency, last);
    SET id = LAST_INSERT_ID();
END //

DROP PROCEDURE IF EXISTS listTimedMaints //
CREATE PROCEDURE listTimedMaints (paginate_count INT, paginate_offset INT, OUT paginate_total INT)
BEGIN
	SELECT *
            FROM timedMaint ORDER BY name
            LIMIT paginate_count
            OFFSET paginate_offset;
        SELECT COUNT(*) INTO paginate_total FROM hourlyMaint;
END //

DROP PROCEDURE IF EXISTS modifyTimedMaint //
CREATE PROCEDURE modifyTimedMaint (_id INT, name VARCHAR(128), frequency INT, last DATE, OUT result VARCHAR(255))
BEGIN
    UPDATE timedMaint as h SET
        h.name = name,
        h.frequency = frequency,
        h.last = last
        WHERE h.id = _id;
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS deleteTimedMaint //
CREATE PROCEDURE deleteTimedMaint (_id INT, OUT result VARCHAR(255))
BEGIN
    DELETE FROM timedMaint WHERE timedMaint.id = _id;
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS planeStatus //
CREATE PROCEDURE planeStatus ()
BEGIN
    DECLARE current_tach DECIMAL(8,2);

    SELECT MAX(endTach) FROM logs INTO current_tach;

    SELECT name, last + frequency AS next,
        last + frequency - current_tach AS remaining
        FROM hourlyMaint;

    SELECT name, ADDDATE(last, frequency) AS next,
        DATEDIFF(ADDDATE(last, frequency), NOW()) AS remaining
        FROM timedMaint;
END //

DROP PROCEDURE IF EXISTS runBilling //
CREATE PROCEDURE runBilling (OUT result VARCHAR(255))
BEGIN
    UPDATE logs SET billedDate = NOW() WHERE billedDate IS NULL;
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS listRoles //
CREATE PROCEDURE listRoles ()
BEGIN
	SELECT 'logs_normalUser', 'Normal';
END //

CREATE ROLE IF NOT EXISTS logs_normalUser;

GRANT EXECUTE ON PROCEDURE createLogSimple TO logs_normalUser;
GRANT EXECUTE ON PROCEDURE listLogs TO logs_normalUser;
GRANT EXECUTE ON PROCEDURE planeStatus TO logs_normalUser;
GRANT EXECUTE ON PROCEDURE lastTimes TO logs_normalUser;
GRANT EXECUTE ON PROCEDURE listHourlyMaints TO logs_normalUser;
GRANT EXECUTE ON PROCEDURE listTimedMaints TO logs_normalUser;
GRANT EXECUTE ON PROCEDURE modifyHourlyMaint TO logs_normalUser;
GRANT EXECUTE ON PROCEDURE modifyTimedMaint TO logs_normalUser;
