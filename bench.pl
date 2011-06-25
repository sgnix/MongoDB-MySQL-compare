#!/usr/bin/perl

use strict;
use warnings;

use Benchmark;
use Getopt::Long;

my $database = 'Test';

my $accounts    = 1000;
my $posts       = 100;
my $text_length = 1000;

my $create  = 1;
my $update  = 0;
my $runs    = 10;
my $verbose = 1;

my %local = ();

GetOptions(
    "database=s" => \$database,
    "accounts=i" => \$accounts,
    "posts=i"    => \$posts,
    "textlen=i"  => \$text_length,
    "verbose"    => \$verbose,
    "quiet"      => sub { $verbose = 0 },
    "create"     => \$create,
    "update"     => \$update,
    "readonly"   => sub { $create = 0 },
    "runs=i"     => \$runs,
    "local=s"    => \%local
);

$| = $verbose;

my $module = $ARGV[0];
if ( !defined $module ) {
    die "Missing module name";
}
elsif ( not eval "use Bench::$module; 1;" ) {
    die "Module Bench::$module not found";
}

my %args = (
    database    => $database,
    accounts    => $accounts,
    posts       => $posts,
    text_length => $text_length,
    update      => $update,
    verbose     => $verbose,
    %local
);

my $bench = eval "Bench::$module->new(\%args);";

if ($create) {
    printf("Initializing ...\n") if $verbose;
    $bench->init();

    printf( "Creating %i accounts with %i posts each\n",
        $bench->accounts, $bench->posts )
      if $verbose;
    timethis( 1, sub { $bench->create_data() } );
}

printf( "Reading %i posts %i times ...\n",
    $bench->accounts * $bench->posts, $runs )
  if $verbose;
timethis( $runs, sub { $bench->read_data() } );

__END__

=head1 NAME

bench.pl - database benchmark utility

=head1 SYNOPSIS

    bench.pl module [--database=<name>] [--accounts=<number>]
                    [--posts=<number>] [--textlen=<number>]
                    [--runs=<number>] [--verbose | --quiet]
                    [--create | --readonly] [--update]
                    [--local <name=value>]


=head1 DESCRIPTION

bench.pl is a quick script that tests the performance and CPU usage
of MongoDB and MySQL. It tries to simulate the structure of an orginary
blog, by creating a number of user accounts and a number of posts for 
each account. After that, bench.pl reads all posts several times and
outputs benchmark information. So this is a two step test: one to create
the data and seconds to read it.

=head1 OPTIONS

=head2 --database=<name>

Name of the database to use. The default is I<Test>.

=head2 --accounts=<number>

Number of accounts to create. 

=head2 --posts=<number>

Number of posts to create for each account

=head2 --textlen=<number>

Size in characters for each post

=head2 --runs=<number>

Number of times to read all posts. Higher number will produce more
acurate benchmarks.

=head2 --create

Forces creating the data

=head2 --readonly

If you already have created the data, this option will force the script
to only do the read benchmark.

=head2 --update

This introduces a new test that updates all posts while reading them.

=head2 --verose

Display information and a counter of created accounts and posts

=head2 --quiet

Do not display any information

=head2 --local=<name=value>

Add parameters local to the database driver tested.

=head3 Mongo

=head4 --safe_insert=<1|0>

Use safe_insert. Default is 0.

=head4 --native_id=<1|0>

Use the MongoDB native _id generation or simple integer. Default 0,
i.e. _id is a simple integer.

=head3 MySQL

=head4 --db_user=<username>

Username for the connection. Default is 'test'.

=head4 --db_pass=<password>

Password for the connection. Default is 'test'.

=head1 PREREQUISITS

In order to run this, you'll have to have a few things ready:

=over

=item 1

Install and start MongoDB and MySQL

=item 2

Install the following Perl modules:
    MongoDB
    DBI
    DBD::mysql
    Mouse

=item 3

Create a MySQL database called 'Test' and grant all privileges to 
username test@localhost identified by 'test'

=back

=cut

