use account;

create table useraccount (
       id           INT PRIMARY KEY AUTO_INCREMENT,
       username     VARCHAR(100) NOT NULL,
       password     VARCHAR(100) NOT NULL,
       email        VARCHAR(120) NOT NULL,
       realname     VARCHAR(120) NOT NULL,
       address      VARCHAR(120) NOT NULL,
       status       TINYINT NOT NULL,
       action       TINYINT NOT NULL
);
