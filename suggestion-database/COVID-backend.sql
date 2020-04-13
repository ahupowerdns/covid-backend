
-- Note that everything in this file is a suggestion.
-- In other words: Nothing in this file is definitive.

-- PoC MySQL database schema for use in the COVID-19 backend.

-- DROP-section
-- Here for convenience during development.

DROP VIEW IF EXISTS view_daily_tracing_key_submitted_by_users;
DROP VIEW IF EXISTS view_users_sessions;

DROP TABLE IF EXISTS retracted_daily_tracing_keys;
DROP TABLE IF EXISTS active_daily_tracing_keys;

DROP TABLE IF EXISTS daily_tracing_key_activation_requests;

DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS users;

-- Users Table

-- This will probably change as we move further into the future.
-- For now, assume that every authorized health-care provider receives
-- their login-data by registered mail.

CREATE TABLE IF NOT EXISTS users (
	user_uuid VARCHAR(36) NOT NULL DEFAULT UUID(), -- Unique UUID of user.
	username VARCHAR(32) NOT NULL, -- Unique username of user
	hashed_password VARCHAR(64) NOT NULL, -- Salted password hash.
	salt VARCHAR(32) NOT NULL, -- User specific salt for password.
	totp_seed VARCHAR(32) NOT NULL, -- User specific seed for HMAC-TOTP authentication.
	email VARCHAR(255) NOT NULL, -- E-mail address of user.
	phone_number VARCHAR(20) NOT NULL, -- Phone number on which the user has to be near-instantly available so we can reach them if their account shows suspicious activity.
	reset_code VARCHAR(64) NULL DEFAULT NULL, -- Password reset code.
	active BOOLEAN NOT NULL DEFAULT FALSE, -- Is account active?
	account_expiration_date DATE NOT NULL DEFAULT DATE_ADD(CURDATE(), INTERVAL 2 YEAR), -- Automatic expiration after 2 years.
	PRIMARY KEY (user_uuid), 
	KEY (username),
	UNIQUE (username),
	KEY (email, reset_code),
	UNIQUE (email),
	UNIQUE (phone_number)
);

CREATE TABLE IF NOT EXISTS user_sessions (
	user_uuid VARCHAR(36) NOT NULL, -- user_uuid of session
	active BOOLEAN NOT NULL DEFAULT TRUE, -- Wether or not this session is active.
	session_token VARCHAR(36) NOT NULL, -- Token used to identify a session.
	begin_time TIMESTAMP NOT NULL DEFAULT NOW(), -- Time of session start.
	expiration_time TIMESTAMP NOT NULL DEFAULT DATE_ADD(NOW(), INTERVAL 30 MINUTE), -- Timestamp after which a session naturally expires if it has not been used.
	PRIMARY KEY (session_token),
	KEY (session_token, user_uuid),
	FOREIGN KEY (user_uuid) REFERENCES users(user_uuid) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS daily_tracing_key_activation_requests (
	request_uuid VARCHAR(36) NOT NULL DEFAULT UUID(), -- UUID of activation request.
	user_uuid VARCHAR(36) NULL, -- UUID of user who made the activation request.
	valid_until TIMESTAMP NOT NULL DEFAULT DATE_ADD(NOW(), INTERVAL 2 HOUR), -- Expiration timestamp of the user's session.
	request_token VARCHAR(36) NOT NULL, -- Single use token which can be used to submit daily_tracing_keys.
	time_received TIMESTAMP NULL DEFAULT NULL, -- Time at which the daily_tracing_keys have been received.
	PRIMARY KEY (request_uuid),
	KEY (request_uuid, user_uuid),
	KEY (time_received),
	FOREIGN KEY (user_uuid) REFERENCES users(user_uuid) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS active_daily_tracing_keys (
	request_uuid VARCHAR(36) NOT NULL, -- UUID of activation request.
	day_number DATE NOT NULL, -- Day number belonging to the daily_tracing_key.
	daily_tracing_key BINARY(16) NOT NULL, -- daily_tracing_key.
	PRIMARY KEY(request_uuid, day_number, daily_tracing_key),
	KEY (day_number, daily_tracing_key),
	FOREIGN KEY (request_uuid) REFERENCES daily_tracing_key_activation_requests(request_uuid) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS retracted_daily_tracing_keys (
	retraction_uuid VARCHAR(36) NOT NULL DEFAULT UUID(), -- uuid of the retraction-event.
	user_uuid VARCHAR(36) NOT NULL, -- uuid of the user who issued the retraction event.
	activation_request_uuid VARCHAR(36) NULL, -- uuid of the activation request the retracted daily_tracing_key appeared in.
	time_of_retraction TIMESTAMP NOT NULL DEFAULT NOW(), -- timestamp of when the retraction was issued.
	day_number DATE NOT NULL, -- Day number belonging to the daily_tracing_key.
	daily_tracing_key BINARY(16) NOT NULL, -- daily_tracing_key.
	PRIMARY KEY (retraction_uuid),
	FOREIGN KEY (user_uuid) REFERENCES users(user_uuid) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (day_number, daily_tracing_key) REFERENCES active_daily_tracing_keys(day_number, daily_tracing_key) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (activation_request_uuid) REFERENCES active_daily_tracing_keys(request_uuid) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Views for use by application.

-- View to be used to check if a user is currently logged in.

CREATE OR REPLACE VIEW view_users_sessions AS
SELECT 
	users.user_uuid AS user_uuid,
    users.username AS username,
    users.active AS user_active,
    user_sessions.active AS session_active,
    user_sessions.begin_time AS session_begin_time,
    user_sessions.expiration_time AS session_expiration_time
FROM
	users, user_sessions
WHERE
	users.user_uuid = user_sessions.user_uuid;

-- View to show the user all daily_tracing_keys he or she has submitted.

CREATE OR REPLACE VIEW view_daily_tracing_key_submitted_by_users AS
SELECT
	users.username AS username,
	dtkars.time_received AS time_received,
	adtks.day_number AS day_number,
    adtks.daily_tracing_key AS daily_tracing_key
FROM
	users,
	daily_tracing_key_activation_requests AS dtkars,
    active_daily_tracing_keys AS adtks
WHERE
	users.user_uuid = dtkars.user_uuid AND
    dtkars.request_uuid = adtks.request_uuid;
