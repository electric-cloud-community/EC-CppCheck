# -------------------------------------------------------------------------
# Package
#    cppcheckDriver.pl
#
# Dependencies
#    None
#
# Purpose
#    Use CppCheck tool features on Electric Commander
#
# Plugin Version
#    1.0.1
#
# Date
#    09/29/2011 
#
# Engineer
#    Carlos Rojas
#
# Copyright (c) 2011 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use ElectricCommander;
use warnings;
use strict;
use Cwd;
$|=1;




# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
$::gInstallPath = "$[installpath]";
$::gTarget = q($[target]);
$::gVerbosity = "$[verbose]";
$::gForce = "$[force]";
$::gQuietMode = "$[quiet]";
$::gEnableChecks = "$[enable]";
$::gUseXMLLogFormat = "$[usexml]";
$::gOutputFile = "$[outputfile]";
$::gAdditionalCommands = q($[commands]);
$::gWorkingDir = "$[workingdir]";



# -------------------------------------------------------------------------
# Main functions
# -------------------------------------------------------------------------

########################################################################
# main - contains the whole process to be done by the plugin, it builds the
#        command line, sets the properties and the working directory
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
########################################################################
sub main() {
    
    # create args array
    my @args = ();
    
    #properties' map
    my %props;
    
    my $pathToReport;
    
    #add path to exec if entered
    my $executable = '';
    
    if($::gInstallPath && $::gInstallPath ne ''){
        $executable = $::gInstallPath;
    }
    
    if($::gInstallPath && lc($::gInstallPath) ne "cppcheck"){
        $executable = '"'. $executable . '\\cppcheck"';
    }
        
    push(@args, $executable );
    
    if($::gAdditionalCommands  && $::gAdditionalCommands  ne '') {
        foreach my $command (split(' +', $::gAdditionalCommands)) {
	    	push(@args, "$command");
		}
    }
    
    if($::gForce && $::gForce ne '') {
        push(@args, '-f');
    }    

    if($::gVerbosity && $::gVerbosity ne '') {
        push(@args, '-v');
    }
    
    if($::gQuietMode && $::gQuietMode ne '') {
        push(@args, '-q');
    }
    
    if($::gUseXMLLogFormat && $::gUseXMLLogFormat ne '') {
        push(@args, '--xml');
    }
    
    if($::gEnableChecks && $::gEnableChecks ne '') {
        push(@args, '--enable='.$::gEnableChecks);
    }    
    
    if($::gTarget && $::gTarget ne '') {
        push(@args, $::gTarget );
    }    
    
    if($::gOutputFile && $::gOutputFile ne '') {
        push(@args, '> "' . $::gOutputFile . '"');
    }   
    
    #In case the user define a custom wd we need to copy the reportfile 
    if($::gWorkingDir && $::gWorkingDir ne "" && $::gOutputFile && $::gOutputFile ne "")
    {
        if($^O eq 'linux'){
            $props{'copyCommand'} = 'cp "'. $::gWorkingDir . "/" . $::gOutputFile . '" '. '"' . cwd . '"';
        }else{
            $props{'copyCommand'} = 'copy "'. $::gWorkingDir . "/" . $::gOutputFile . '" '. '"' . cwd . '"';
        }
    }
    else
    {
        $props{'copyCommand'} = "";
    }
    
    #generate the command to execute in console
    $props{'commandLine'} = createCommandLine(\@args);
    $props{'workingdir'} = $::gWorkingDir;
    
    registerReports();
    
    setProperties(\%props);
    
}

########################################################################
# createCommandLine - builds up the command line that will be executed 
#                     by the plugin
#
# Arguments:
#   -arr: array containing the command name in the first position and the
#         arguments in the following positions
#
# Returns:
#   -a string with the command line
#
########################################################################
sub createCommandLine($) {

  	my ($arr) = @_;

    my $commandName = @$arr[0];

    my $command = $commandName;

    shift(@$arr);

	foreach my $elem (@$arr) {
        $command .= " $elem";
    }

    return $command;
    
}

########################################################################
# registerReports - creates a link for registering the generated report
# in the job step detail
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
########################################################################
sub registerReports(){
 
 
    if($::gOutputFile && $::gOutputFile ne ''){
     
         # get an EC object
         my $ec = new ElectricCommander();
         $ec->abortOnError(0);
      
         $ec->setProperty("/myJob/artifactsDirectory", '');
         
         my $fileName = '';
         my $fileIndex = rindex($::gOutputFile, '/');
         
         if($fileIndex == -1){
          
            $fileIndex = (rindex($::gOutputFile, '\\'));
          
         }
         
         if($fileIndex == -1){
          
            $fileName = $::gOutputFile;
          
         }else{
          
            $fileName = substr($::gOutputFile, $fileIndex+1, length($::gOutputFile)-$fileIndex);
          
         }
         
         $ec->setProperty("/myJob/report-urls/CppCheck Report", "jobSteps/$[jobStepId]/" . $fileName);
     
    }
 


}

########################################################################
# setProperties - set a group of properties into the Electric Commander
#
# Arguments:
#   -propHash: hash containing the ID and the value of the properties 
#              to be written into the Electric Commander
#
# Returns:
#   -nothing
#
########################################################################
sub setProperties($) {

    my ($propHash) = @_;

    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);

    foreach my $key (keys % $propHash) {
        my $val = $propHash->{$key};
        $ec->setProperty("/myCall/$key", $val);
    }
}

main();

