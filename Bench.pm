package Bench;

use Mouse;
use List::Util qw/shuffle/;

has database => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
    default  => 'Test'
);

has db => (
    isa      => 'Object',
    is       => 'ro',
    required => 1
);

has accounts => (
    isa      => 'Int',
    is       => 'ro',
    default  => 1000,
    required => 1
);

has posts => (
    isa      => 'Int',
    is       => 'ro',
    default  => 200,
    required => 1
);

has text_length => (
    isa      => 'Int',
    is       => 'ro',
    default  => 1000,
    required => 1
);

has update => (
    isa      => 'Bool',
    is       => 'ro',
    default  => 0,
    required => 1
);

sub init        { ... }
sub add_account { ... }
sub add_post    { ... }
sub get_ids     { ... }
sub read_posts  { ... }
sub update_post { ... }

sub create_data {
    my $self = shift;
    my $ids  = $self->create_accounts();
    $self->create_posts($ids);
    return $ids;
}

sub create_accounts {
    my $self = shift;
    my @ids  = ();
    for ( 0 .. $self->accounts - 1 ) {
        my $name = 'name' . int( rand( $self->accounts ) );
        my $id   = $self->add_account($name);
        push @ids, $id;
    }
    return \@ids;
}

sub create_posts {
    my ( $self, $ids ) = @_;
    for ( 0 .. $self->posts - 1 ) {
        for my $account_id (@$ids) {
            $self->add_post($account_id);
        }
    }
}

sub read_data {
    my $self = shift;
    my $ids = shift || $self->get_ids();
    for my $account_id ( shuffle @$ids ) {
        $self->read_posts($account_id);
    }
}

__PACKAGE__->meta->make_immutable;
1;
