#!/usr/bin/perl -w
use strict;
use Getopt::Long;
my %VARIABLES;
my $snippet_base_dir="/home/christophermotes/git/kickstart_generator/snippets";
#my $VARIABLES{ 'KS_NAME' }='default';
GetOptions ( \%VARIABLES,  
        'KS_NAME=s',
        'IPADDRESS=s', 
        'HOSTNAME=s', 
        'IPNETMASK=s',
        'IPGATEWAY=s', 
        'BACKUPIP=s',
        'BACKUPNETMASK=s',
        'BACKUPGATEWAY=s', );

if ( keys (%VARIABLES) < 9 ) { error_help (); }
my $SOURCE_DIR="/opt/kickstart/base_files/${VARIABLES{'KS_NAME'}}";
my $DEST_DIR="/home/christophermotes/kickstart/${VARIABLES{'HOSTNAME'}}";
my $KS_FILE="${DEST_DIR}/isolinux/ks.cfg";
my $KS_TMP_FILE="${DEST_DIR}/isolinux/ks.cfg.tmp";
my @snipette_dir_names = ( "~/.ks_generator", "$snippet_base_dir/$VARIABLES{ 'KS_NAME' }" );
my @required_snippets = ( 'header', 'install', 'network', 'users', 'other', 'repos', 'packages', 'post', );
my @replacable_snippets = ( 'disk', );
my @snippets = ( 'header', 'install', 'network', 'users', 'other', 'disk', 'repos', 'packages', 'post', );

my %snippet_hash;
for my $required_snippet (@required_snippets) {
	if ( -r "$snippet_base_dir/${required_snippet}.required") {
		print "Found  $snippet_base_dir/${required_snippet}.required\n";
		push @{ $snippet_hash{ $required_snippet } }, "${snippet_base_dir}/${required_snippet}.required";

	} else {
		print "Not found $snippet_base_dir/${required_snippet}.required\n";
		exit 4;
	}
}
for my $replacable_snippet (@replacable_snippets) {
	for my $working_dir (@snipette_dir_names) {
		if ( -r "$working_dir/${replacable_snippet}.default") {
			print "Found  $working_dir/${replacable_snippet}.default\n";
			push @{ $snippet_hash{ $replacable_snippet } }, "$working_dir/${replacable_snippet}.default";
			last;
		}
	}
}
for my $full_file_list  (@snippets) {
	for my $working_dir (@snipette_dir_names) {
		my @globber = glob "$working_dir/$full_file_list.[0-9]*";
		for (@globber) { print "Found $_\n"; }
		push @{ $snippet_hash{ $full_file_list } }, @globber;
	}
}
##create the isolinux directory for source dir
if ( -d $SOURCE_DIR ) {
	if ( -d $DEST_DIR ) {
		die "$DEST_DIR exists, remove it\n" ;
	} else {
		`cp -p -r $SOURCE_DIR $DEST_DIR`;
	} # if dest dir
} else {
	die "$SOURCE_DIR does not exist\n";
} # end if SOURCE_DIR

open (KS_HANDLE, ">", "$KS_TMP_FILE") or die "KS_HANDLE blows goats: $!";
for my $snippet_name (@snippets) {
	for my $filename (@ { $snippet_hash{ $snippet_name } }) {
		chomp($filename);
		open (SNIP_NAME, "<", "$filename") or die "fuck you $filename";
		while (<SNIP_NAME>) {
			print KS_HANDLE;
		}
		close SNIP_NAME;
	}
}
close KS_HANDLE;

## hear we update the ks.cfg file
open (KS_OUT_HANDLE, ">$KS_FILE") or die "cannot open $KS_FILE\n";
open (KS_IN_HANDLE, "<$KS_TMP_FILE") or die "cannot open this file $KS_TMP_FILE";
while (<KS_IN_HANDLE>) {
  	my $working_string=$_;
	#here we pull the values from the hash and compare to each string
	while ( (my $work_key, my $work_val) = each %VARIABLES ) {
	$working_string =~ s/$work_key/$work_val/g;
	} # end while each
	#print to file
	print KS_OUT_HANDLE $working_string;
} # while KS_FILE_HANDLE
close KS_IN_HANDLE;
close KS_OUT_HANDLE;
`rm $KS_TMP_FILE`;
chdir "$DEST_DIR";
my $dash_o = "-o${VARIABLES{'HOSTNAME'}}.ks.iso";
my @iso_exec = ( "/usr/bin/mkisofs", $dash_o, "-b", "isolinux.bin", "-c", "boot.cat", "-no-emul-boot", "-boot-load-size", " 4", "-boot-info-table", "-R", "-J", "-v", "-T", "isolinux/" );
system (@iso_exec);
sub error_help {
	print "kick start builder requires the following options:\n";
	print "\t--KS_NAME \n\t--BACKUPGATEWAY \n\t--BACKUPIP \n\t--BACKUPNETMASK \n\t--HOSTNAME \n\t--IPADDRESS \n\t--IPGATEWAY \n\t--IPNETMASK \n\t--SYSLOCATION \n";
} # close  error_help
