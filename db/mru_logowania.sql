
CREATE TABLE IF NOT EXISTS `mru_logowania` (
`UID` bigint(20) NOT NULL,
  `PID` int(7) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(16) COLLATE utf8_polish_ci NOT NULL,
  `gpci` varchar(128) COLLATE utf8_polish_ci DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1387266 DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci;


ALTER TABLE `mru_logowania`
 ADD PRIMARY KEY (`UID`), ADD KEY `PID` (`PID`);


ALTER TABLE `mru_logowania`
MODIFY `UID` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1387266;