package Bench::MySQL;
use Mouse;
extends 'Bench';

use DBI;

has db_user => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'test'
);

has db_pass => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'test'
);

has '+db' => (
    isa        => 'DBI::db',
    is         => 'ro',
    required   => 1,
    lazy_build => 1
);

sub _build_db {
    my $self = shift;
    return DBI->connect(
        "dbi:mysql:" . $self->database, 
        $self->db_user, 
        $self->db_pass,
        { AutoCommit => 1, PrintError => 1, RaiseError => 1 }
    );
}

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
           PRIMARY KEY (`id`),
           INDEX i1 (`account_id`)
        ) ENGINE = MyISAM;
    ]);
}

sub add_account {
    my ( $self, $name ) = @_;
    $self->db->do( 'INSERT INTO Accounts (`name`) VALUES (?)', {}, $name );
    return $self->db->last_insert_id( undef, undef, undef, undef );
}

sub add_post {
    my ( $self, $account_id ) = @_;
    $self->db->do( 
        q[ INSERT INTO Posts( account_id, text ) VALUES(?, ?) ],
        {}, $account_id, 'A' x $self->text_length 
    );
    return $self->db->last_insert_id( undef, undef, undef, undef );
}

sub get_ids {
    my $self = shift;
    my @ids  = ();
    my $sth  = $self->db->prepare(q[SELECT id from Accounts]);
    $sth->execute();
    while ( my $id = $sth->fetchrow_array ) {
        push @ids, $id;
    }
    return \@ids;
}

sub read_posts {
    my ( $self, $account_id ) = @_;
    my $sth = $self->db->prepare( q[SELECT * FROM Posts WHERE account_id = ?] );
    $sth->execute($account_id);
    while ( my $row = $sth->fetchrow_hashref ) {
        if ( $self->update ) {
            $self->update_post( $row->{id} );
        }
    }
}

sub update_post {
    my ( $self, $post_id ) = @_;
    $self->db->do( 
        q[UPDATE Posts SET text = ?  WHERE id = ?],
        {}, 'B' x $self->text_length, $post_id 
    );
}

__PACKAGE__->meta->make_immutable;
1;
