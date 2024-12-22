DROP FUNCTION IF EXISTS online_library_init.online_library_db_init;

DROP SCHEMA IF EXISTS online_library_init;

CREATE SCHEMA online_library_init AUTHORIZATION library_owner;

CREATE OR REPLACE FUNCTION online_library_init.online_library_db() RETURNS VOID AS $$
BEGIN
	
END
$$ LANGUAGE plpgsql;

