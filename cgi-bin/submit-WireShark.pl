#!/usr/bin/perl -w
# Program: cass_sample.pl
# Note: includes bug fixes for Net::Async::CassandraCQL 0.11 version

use strict;
use warnings;
use 5.10.0;
use FindBin;

use Thrift::IDL;
use Thrift::Parser;

use Thrift;
use Thrift::MemoryBuffer;
use Thrift::BinaryProtocol;
use Thrift::JSONProtocol;
use lib 'gen-perl';
use Types;
use Scalar::Util qw(
        blessed
    );
use Try::Tiny;

use Kafka::Connection;
use Kafka::Producer;

use Data::Dumper;
use CGI qw/:standard/, 'Vars';

my $params = Vars;
my $buffer = Thrift::MemoryBuffer->new();
my $protocol = Thrift::JSONProtocol->new($buffer);

my $source_new = Source_new->new($params);

my @sourceFields = ('number','time','source','destination','protocol','info','length');

my ( $connection, $producer );
try {

    #-- Connection
    $connection = Kafka::Connection->new( host => 'localhost' );

    #-- Producer
    $producer = Kafka::Producer->new( Connection => $connection );
    $source_new->write($protocol);

    # Sending a single message
    my $response = $producer->send(
	'source-submissions',          # topic
	0,                  # partition
	$protocol->getTransport->getBuffer    # message
        );
} catch {
    if ( blessed( $_ ) && $_->isa( 'Kafka::Exception' ) ) {
	warn 'Error: (', $_->code, ') ',  $_->message, "\n";
	exit;
    } else {
	die $_;
    }
};

# Closes the producer and cleans up
undef $producer;
undef $connection;

print header, start_html(-title=>'Submit WireShark',-head=>Link({-rel=>'stylesheet',-href=>'/table.css',-type=>'text/css'}));
print table({-class=>'CSS_Table_Example', -style=>'width:80%;'},
            caption('Source submitted'),
	    Tr([td(\@sourceFields),
	        td([$source_new->number,$source_new->time,$source_new->source,$source_new->destination,$source_new->protocol,$source_new->info,$source_new->length])]));

print end_html;

