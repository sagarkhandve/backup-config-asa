#!/usr/bin/perl
#Function: Backup/restore configuration/extensions to/from a TFTP server.
#Description: The objective of this script is to show how to back up configurations/extensions before the backup/restore command is developed.
# It currently backs up the running configuration, all extensions imported via “import webvpn” command, the CSD configuration XML file, and the DAP configuration XML file.
#Requirements: Perl with Expect, SSH to the ASA, and a TFTP server.
#Usage: backupasa -option option_value
# -h: ASA hostname or IP address
# -u: User name to log in via SSH
# -w: Password to log in via SSH
# -e: The Enable password on the security appliance
# -p: Global configuration mode prompt
# -s: Host name or IP address of the TFTP server to store the configurations
# -r: Restore with an argument that specifies the file name. This file is produced during backup.
#If you don't enter an option, the script will prompt for it prior to backup.
#
#Make sure that you can SSH to the ASA.
use Expect;
use Getopt::Std;
 
#global variables
%options=();
$restore = 0; #does backup by default
$restore_file = ‘’;
$asa = ‘’;
$storage = ‘’;
$user = ‘’;
$password = ‘’;
$enable = ‘’;
$prompt = ‘’;
$date = `date +%F’;
chop($date);
my $exp = new Expect();
 
getopts(“h:u:p:w:e:s:r:”,\%options);
do process_options();
 
do login($exp);
do enable($exp);
if ($restore) {
do restore($exp,$restore_file);
}
else {
$restore_file = “$prompt-restore-$date.cli”;
open(OUT,”>$restore_file”) or die “Can't open $restore_file\n”;
do running_config($exp);
do lang_trans($exp);
do customization($exp);
do plugin($exp);
do url_list($exp);
do webcontent($exp);
do dap($exp);
do csd($exp);
close(OUT);
}
do finish($exp);
 
sub enable {
$obj = shift;
$obj->send(“enable\n”);
unless ($obj->expect(15, ‘Password:’)) {
print “timed out waiting for Password:\n”;
}
$obj->send(“$enable\n”);
unless ($obj->expect(15, “$prompt#”)) {
print “timed out waiting for $prompt#\n”;
}
}
 
sub lang_trans {
$obj = shift;
$obj->clear_accum();
$obj->send(“show import webvpn translation-table\n”);
$obj->expect(15, “$prompt#”);
$output = $obj->before();
@items = split(/\n+/, $output);
 
for (@items) {
s/^\s+//;
s/\s+$//;
next if /show import/ or /Translation Tables/;
next unless (/^.+\s+.+$/);
($lang, $transtable) = split(/\s+/,$_);
$cli = “export webvpn translation-table $transtable language $lang $storage/$prompt-$date-$transtable-$lang.po”;
$ocli = $cli;
$ocli =~ s/^export/import/;
print “$cli\n”;
print OUT “$ocli\n”;
$obj->send(“$cli\n”);
$obj->expect(15, “$prompt#”);
}
}
 
sub running_config {
$obj = shift;
$obj->clear_accum();
$cli =“copy /noconfirm running-config $storage/$prompt-$date.cfg”;
print “$cli\n”;
$obj->send(“$cli\n”);
$obj->expect(15, “$prompt#”);
}
 
 
sub customization {
$obj = shift;
$obj->clear_accum();
$obj->send(“show import webvpn customization\n”);
$obj->expect(15, “$prompt#”);
$output = $obj->before();
@items = split(/\n+/, $output);
 
for (@items) {
chop;
next if /^Template/ or /show import/ or /^\s*$/;
$cli = “export webvpn customization $_ $storage/$prompt-$date-cust-$_.xml”;
$ocli = $cli;
$ocli =~ s/^export/import/;
print “$cli\n”;
print OUT “$ocli\n”;
$obj->send(“$cli\n");
$obj->expect(15, “$prompt#”);
}
}
 
sub plugin {
$obj = shift;
$obj->clear_accum();
$obj->send(“show import webvpn plug-in\n”);
$obj->expect(15, “$prompt#”);
$output = $obj->before();
@items = split(/\n+/, $output);
 
for (@items) {
chop;
next if /^Template/ or /show import/ or /^\s*$/;
$cli = “export webvpn plug-in protocol $_ $storage/$prompt-$date-plugin-$_.jar”;
$ocli = $cli;
$ocli =~ s/^export/import/;
print “$cli\n”;
print OUT “$ocli\n”;
$obj->send(“$cli\n”);
$obj->expect(15, “$prompt#”);
}
}
 
sub url_list {
$obj = shift;
$obj->clear_accum();
$obj->send(“show import webvpn url-list\n”);
$obj->expect(15, “$prompt#”);
$output = $obj->before();
@items = split(/\n+/, $output);
 
for (@items) {
chop;
next if /^Template/ or /show import/ or /^\s*$/ or /No bookmarks/;
$cli=“export webvpn url-list $_ $storage/$prompt-$date-urllist-$_.xml”;
$ocli = $cli;
$ocli =~ s/^export/import/;
print “$cli\n”;
print OUT “$ocli\n”;
$obj->send(“$cli\n”);
$obj->expect(15, “$prompt#”);
}
}
 
sub dap {
$obj = shift;
$obj->clear_accum();
$obj->send(“dir dap.xml\n”);
$obj->expect(15, “$prompt#”);
 
$output = $obj->before();
return 0 if($output =~ /Error/);
 
$cli=“copy /noconfirm dap.xml $storage/$prompt-$date-dap.xml”;
$ocli=“copy /noconfirm $storage/$prompt-$date-dap.xml disk0:/dap.xml”;
print “$cli\n”;
print OUT “$ocli\n”;
$obj->send(“$cli\n”);
$obj->expect(15, “$prompt#”);
}
 
sub csd {
$obj = shift;
$obj->clear_accum();
$obj->send(“dir sdesktop\n”);
$obj->expect(15, “$prompt#”);
 
$output = $obj->before();
return 0 if($output =~ /Error/);
 
$cli=“copy /noconfirm sdesktop/data.xml $storage/$prompt-$date-data.xml”;
$ocli=“copy /noconfirm $storage/$prompt-$date-data.xml disk0:/sdesktop/data.xml”;
print “$cli\n”;
print OUT “$ocli\n”;
$obj->send(“$cli\n”);
$obj->expect(15, “$prompt#”);
}
 
sub webcontent {
$obj = shift;
$obj->clear_accum();
$obj->send(“show import webvpn webcontent\n”);
$obj->expect(15, “$prompt#”);
$output = $obj->before();
@items = split(/\n+/, $output);
 
for (@items) {
s/^\s+//;
s/\s+$//;
next if /show import/ or /No custom/;
next unless (/^.+\s+.+$/);
($url, $type) = split(/\s+/,$_);
$turl = $url;
$turl =~ s/\/\+//;
$turl =~ s/\+\//-/;
$cli = “export webvpn webcontent $url $storage/$prompt-$date-$turl”;
$ocli = $cli;
$ocli =~ s/^export/import/;
print “$cli\n”;
print OUT “$ocli\n”;
$obj->send(“$cli\n”);
$obj->expect(15, “$prompt#”);
}
}
 
sub login {
$obj = shift;
$obj->raw_pty(1);
$obj->log_stdout(0); #turn off console logging.
$obj->spawn(“/usr/bin/ssh $user\@$asa”) or die “can't spawn ssh\n”;
unless ($obj->expect(15, “password:”)) {
die “timeout waiting for password:\n”;
}
 
$obj->send(“$password\n”);
 
unless ($obj->expect(15, “$prompt>”)) {
die “timeout waiting for $prompt>\n”;
}
}
 
sub finish {
$obj = shift;
$obj->hard_close();
print “\n\n”;
 
}
 
sub restore {
$obj = shift;
my $file = shift;
my $output;
open(IN,“$file”) or die “can't open $file\n”;
while (<IN>) {
$obj->send(“$_”);
$obj->expect(15, “$prompt#”);
$output = $obj->before();
print “$output\n”;
}
close(IN);
}
 
sub process_options {
if (defined($options{s})) {
$tstr= $options{s};
$storage = “tftp://$tstr”;
}
else {
print “Enter TFTP host name or IP address:”;
chop($tstr=<>);
$storage = “tftp://$tstr”;
}
if (defined($options{h})) {
$asa = $options{h};
}
else {
print “Enter ASA host name or IP address:”;
chop($asa=<>);
}
if (defined ($options{u})) {
$user= $options{u};
}
else {
print “Enter user name:”;
chop($user=<>);
}
if (defined ($options{w})) {
$password= $options{w};
}
else {
print “Enter password:”;
chop($password=<>);
}
if (defined ($options{p})) {
$prompt= $options{p};
}
else {
print “Enter ASA prompt:”;
chop($prompt=<>);
}
if (defined ($options{e})) {
$enable = $options{e};
}
else {
print “Enter enable password:”;
chop($enable=<>);
}
 
if (defined ($options{r})) {
$restore = 1;
$restore_file = $options{r};
}
}
```