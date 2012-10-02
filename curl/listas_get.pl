#!/usr/bin/env perl
use HTTP::Request;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

my $hash = { active => 0, info => ""};

my $json = JSON->new; 

my $data = encode_json($hash);

my $url = "http://localhost:3000/rest/maillist/";

my $req = HTTP::Request->new(GET => $url);
$req->header("Cookie" =>
    "peribeco_session=0e470fa896e537b495724735a530884251c56982");
$req->content_type('application/json');
#$req->content($data);

my $ua = LWP::UserAgent->new; # You might want some options here
my $res = $ua->request($req);
print $json->pretty->encode($json->decode($res->decoded_content)) , "\n";
print $res->code , "\n";
# $res is an HTTP::Response, see the usual LWP docs.






