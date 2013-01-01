CREATE TABLE `links` (
  `linkid` int(11) NOT NULL auto_increment,
  `siteid` int(11) default NULL,
  `url` varchar(255) NOT NULL,
  `title` varchar(200) default NULL,
  `description` varchar(255) default NULL,
  `fulltext` mediumtext,
  `indexdate` date default NULL,
  `level` int(11) default NULL,
  PRIMARY KEY  (`linkid`),
  KEY `url` (`url`)
);
