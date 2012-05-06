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
my ($configfile) = @ARGV;
my $config = new Config::IniFiles( 
    -file=>$configfile,
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
my $timestamp = POSIX::strftime("%Y-%m-%dT%H:%M:%SZ", gmtime);
#I cheat here and explicitly use the same structure as the link.
#mostly because for my application I don't actually need it. and 
#I dont want to deal with the warning from SimpleFeed telling me
#it is doing just that.
if($config->val('config','format') eq 'feed'){
    my $feed = new XML::Atom::SimpleFeed(
        title   => 'CURRENT STOCK PRICES',
        link    => $config->val('feed','link'),
        id      => $config->val('feed','link'),
        updated => $timestamp,
        author  => 'quotes.pl'
    );
    $feed->add_entry(
        title =>'Prices: '. join(' ',@companies),
        link  =>$config->val('feed','link') . 'stocks/' . $timestamp,
        id  =>$config->val('feed','link') . 'stocks/' . $timestamp,
        summary=>$output,
        updated =>$timestamp 
    );
    $output = $feed->as_string;
} 
#write to file if desired.
if($config->val('config','write') ne 'false'){
    open FILEOUT,'>',$config->val('config','write') or die $!;
    print FILEOUT $output;
    close FILEOUT;
}else{
    print $output . "\n";
}
