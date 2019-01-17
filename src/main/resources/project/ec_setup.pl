my %runCppcheck = (
    label       => "CppCheck - Code Analysis",
    procedure   => "runCppcheck",
    description => "Runs the CppCheck code analysis.",
    category    => "Code Analysis"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/CppCheck - Code Analysis");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-CppCheck - runCppcheck");

@::createStepPickerSteps = (\%runCppcheck);
