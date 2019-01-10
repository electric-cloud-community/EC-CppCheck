@::gMatchers = (
    #invalid target
    {
        id =>        "not-found-target",
        pattern =>       q{could not find or open any of the paths given},
        action =>        q{&addSimpleError("not-found-target", "cppcheck could not find any of the paths given.");updateSummary();},
    },
    #unrecognized option
    {
        id =>        "unrecognized-option",
        pattern =>          q{unrecognized command line option (.*)},
        action =>           q{&addSimpleError("unrecognized-option", "unrecognized command line option $1");updateSummary();},
    },
    #checked files
    {
        id =>        "checked-files",
        pattern =>          q{(\d.*) files checked 100% done},
        action =>           q{&addSimpleError("checked-files", "$1 files checked 100% done");updateSummary();},
    },
    #invalid --enable parameter
    {
        id =>        "invalid-enable-param",
        pattern =>          q{there is no --enable parameter with the name (.*)},
        action =>           q{&addSimpleError("invalid-enable-param", "invalid --enable parameter: $1");updateSummary();},
    },
    #Unused variables
    {
        id =>        "Unused-variable",
        pattern =>          q{Unused variable},
        action =>           q{&incValueWithString("Unused-variable", "0 unused variables detected");updateSummary();},
    },
    #Variables assigned but never used
    {
        id =>        "assigned-never-used",
        pattern =>          q{Variable (.*) is assigned a value that is never used},
        action =>           q{&incValueWithString("assigned-never-used", "0 assigned variables but never used");updateSummary();},
    },
    #Possible null pointer dereference
    {
        id =>       "null-pointer-dereference",
        pattern =>          q{Possible null pointer dereference},
        action =>           q{&incValueWithString("null-pointer-dereference", "0 possible null pointer dereferences");updateSummary();},
    },
    #total warnings
    {
        id =>       "cpp-warning",
        pattern =>          q{\(warning\)},
        action =>           q{&incValueWithString("cpp-warning", "0 warning(s)");updateSummary();},
    },
    #total errors
    {
        id =>       "cpp-errors",
        pattern =>          q{\(error\)},
        action =>           q{&incValueWithString("cpp-errors", "0 error(s)");updateSummary();},
    },
);

sub addSimpleError {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty($name, $customError);
    }
}

sub incValueWithString($;$$) {
    my ($name, $patternString, $increment) = @_;

    $increment = 1 unless defined($increment);

    my $localString = (defined $::gProperties{$name}) ? $::gProperties{$name} :
                                                        $patternString;

    $localString =~ /([^\d]*)(\d+)(.*)/;
    my $leading = $1;
    my $numeric = $2;
    my $trailing = $3;
    
    $numeric += $increment;
    $localString = $leading . $numeric . $trailing;

    setProperty ($name, $localString);
}

sub updateSummary() {
    my $summary = (defined $::gProperties{"unrecognized-option"}) ? $::gProperties{"unrecognized-option"} . "\n" : "";
    $summary   .= (defined $::gProperties{"not-found-target"}) ? $::gProperties{"not-found-target"} . "\n" : "";
    $summary   .= (defined $::gProperties{"checked-files"}) ? $::gProperties{"checked-files"} . "\n" : "";
    $summary   .= (defined $::gProperties{"invalid-enable-param"}) ? $::gProperties{"invalid-enable-param"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cpp-errors"}) ? $::gProperties{"cpp-errors"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cpp-warning"}) ? $::gProperties{"cpp-warning"} . "\n" : "";
    $summary   .= (defined $::gProperties{"Unused-variable"}) ? $::gProperties{"Unused-variable"} . "\n" : "";
    $summary   .= (defined $::gProperties{"assigned-never-used"}) ? $::gProperties{"assigned-never-used"} . "\n" : "";
    $summary   .= (defined $::gProperties{"null-pointer-dereference"}) ? $::gProperties{"null-pointer-dereference"} . "\n" : "";

    setProperty("summary", $summary);
}
