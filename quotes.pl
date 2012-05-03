#! /usr/bin/env perl
#simple script to get quotes for various
#stocks

use warnings;
use strict;
use Finance::YahooQuote;
use Config::IniFiles;
use XML::Atom::SimpleFeed;
use POSIX; 

#read config file
my $config = new Config::IniFiles( 
    -file=>"config.ini",
    -default=>"config"
);

#read the stock symbols from a file
#in which each symbol is on a new line
#and store in an array

my @companies = ();
open COMPANIES, $config->val('config','symbols') or die $!;
while(<COMPANIES>){
    push @companies, $_;
}
close COMPANIES;

my $err = "No companies requested.";
scalar @companies > 0 or die($err);

#process the stock symbols and write it
my @quotes = getquote(@companies);
my $output = '';

foreach (@quotes) {
    my @quote = @$_;
    $output  .= "$quote[0]: ";  #SYMBOL
    $output  .= "\$$quote[2] "; #PRICE
    $output  .= "$quote[5] ";   #CHANGE
    $output  .= "($quote[6])";  #% CHG
    $output  .= "\n";
}
my $timestamp = POSIX::strftime("%Y-%m-%dT%H:%M:%S", localtime);
if($config->val('config','format') eq 'feed'){
    my $feed = new XML::Atom::SimpleFeed(
        title   => 'STOCKS',
        link    => $config->val('feed','link'),
        updated => $timestamp,
        author  => 'quotes.pl'
    );
    $feed->add_entry(
        title =>'stocks',
        link  =>$config->val('feed','link') . $timestamp,
        summary=>$output,
        updated =>$timestamp 
    );
    $feed->print;
} else {
    print "$output\n";
}
