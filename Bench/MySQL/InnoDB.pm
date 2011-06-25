package Bench::MySQL::InnoDB;
use Mouse;
extends 'Bench::MySQL';

use DBI;

sub init {
    my $self = shift;

    $self->db->do(q[DROP TABLE IF EXISTS Posts]);
    $self->db->do(q[DROP TABLE IF EXISTS Accounts]);

    $self->db->do(q[
        CREATE TABLE `Accounts` (
          `id` BIGINT NOT NULL AUTO_INCREMENT ,
          `name` VARCHAR(45) NULL ,
          PRIMARY KEY (`id`) 
        ) ENGINE = InnoDB;
    ]);

    $self->db->do(q[
        CREATE TABLE IF NOT EXISTS `Posts` (
          `id` BIGINT NOT NULL AUTO_INCREMENT ,
          `account_id` BIGINT NOT NULL ,
          `text` TEXT NULL ,
           PRIMARY KEY (`id`) ,
           INDEX `fk_Posts_1` (`account_id` ASC) ,
           CONSTRAINT `fk_Posts_1`
           FOREIGN KEY (`account_id` )
           REFERENCES `Test`.`Accounts` (`id` )
           ON DELETE CASCADE
           ON UPDATE CASCADE
        ) ENGINE = InnoDB;
    ]);
}


__PACKAGE__->meta->make_immutable;
1;
