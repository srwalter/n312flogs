DELIMITER //

DROP PROCEDURE IF EXISTS createLog //
CREATE PROCEDURE createLog (pilot VARCHAR(255), day DATE, end_tach DECIMAL(6,2), end_hobbs DECIMAL(6,2), start_oil DECIMAL(2,2), oil_added DECIMAL(2,2), note VARCHAR(255), OUT logNumber INT)
BEGIN
    INSERT INTO logs (pilot, day, end_tach, end_hobs, start_oil, oil_added, note)
        VALUES (pilot, day, end_tach, end_hobbs, start_oil, oil_added, node);
    SET logNumber = LAST_INSERT_ID();
END //

DROP PROCEDURE IF EXISTS modifyLog //
CREATE PROCEDURE modifyLog (logNumber INT, pilot VARCHAR(255), day DATE, end_tach DECIMAL(6,2), end_hobbs DECIMAL(6,2), start_oil DECIMAL(2,2), oil_added DECIMAL(2,2), note VARCHAR(255), OUT result VARCHAR(255))
BEGIN
    UPDATE logs as l SET
        l.pilot = pilot,
        l.day = day,
        l.end_tach = end_tach,
        l.end_hobbs = end_hobbs,
        l.start_oil = start_oil,
        l.oil_added = oil_added,
        l.note = note
        WHERE l.entry = logNumber;
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS deleteLog //
CREATE PROCEDURE deleteLog (logEntry INT, OUT result VARCHAR(255))
BEGIN
    DELETE FROM logs WHERE logs.entry = logEntry;
    SET result = "Success";
END //

DROP PROCEDURE IF EXISTS listLogs //
CREATE PROCEDURE listTransactions (paginate_count INT, paginate_offset INT, OUT paginate_total INT)
BEGIN
	SELECT *
            FROM logs ORDER BY day
            LIMIT paginate_count
            OFFSET paginate_offset;
        SELECT COUNT(*) INTO paginate_total FROM logs;
END //

