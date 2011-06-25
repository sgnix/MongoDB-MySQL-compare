package Bench::Mongo;
use Mouse;
extends 'Bench';

use MongoDB;

has '+db' => (
    isa        => 'MongoDB::Database',
    is         => 'ro',
    required   => 1,
    lazy_build => 1
);

has safe_insert => (
    isa     => 'Bool',
    is      => 'ro',
    default => 0
);

has native_id => (
    isa     => 'Bool',
    is      => 'ro',
    default => 0
);

sub _build_db {
    my $self     = shift;
    my $database = $self->database;
    return MongoDB::Connection->new()->$database;
}

sub init {
    my $self = shift;
    $self->db->drop();
    $self->db->Posts->ensure_index( { account_id => 1 } );
}

sub add_account {
    my ( $self, $name, $i ) = @_;
    my $rec = { name => $name };
    $rec->{_id} = $i unless $self->native_id;
    return $self->db->Accounts->insert( $rec, { safe => $self->safe_insert } );
}

sub add_post {
    my ( $self, $account_id, $i ) = @_;
    my $rec = {
        account_id => $account_id,
        text       => "A" x $self->text_length
    };
    $rec->{_id} = $i unless $self->native_id;
    return $self->db->Posts->insert( $rec, { safe => $self->safe_insert } );
}

sub get_ids { 
    my $self = shift;
    my @ids = ();
    my $cursor = $self->db->Accounts->find( {} )->fields( { _id => 1 } );
    while ( my $A = $cursor->next ) { push @ids, $A->{_id} }
    return \@ids;
}

sub read_posts { 
    my ($self, $account_id) = @_;
    my $cursor = $self->db->Posts->find( { account_id => $account_id } );
    while ( my $post = $cursor->next ) {
        if ( $self->update ) {
            $self->update_post( $post->{_id} )
        }
    }
}

sub update_post {
    my ( $self, $post_id ) = @_;
    $self->db->Posts->update(
        { _id    => $post_id },
        { '$set' => { text => 'B' x $self->text_length } },
        { upsert => 0, multiple => 0 }
    );
}

__PACKAGE__->meta->make_immutable;
1;
