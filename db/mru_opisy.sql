CREATE TABLE IF NOT EXISTS `mru_opisy` (
`UID` int(11) NOT NULL,
  `typ` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `desc` varchar(128) CHARACTER SET utf8 NOT NULL
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci;


ALTER TABLE `mru_opisy`
 ADD PRIMARY KEY (`UID`), ADD KEY `owner` (`owner`);


ALTER TABLE `mru_opisy`
MODIFY `UID` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=0;