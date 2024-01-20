Add-Type -AssemblyName System.Windows.Forms
$title = "Windows Audio Experience Enhancer"
$msg = @(
    , @("Error", 16)
    , @("Question", 32)
    , @("Exclamation", 48)
    , @("Information", 64)
)

foreach ($m in $msg) {
    if ([System.Windows.Forms.MessageBox]::Show($m[0], $title, 1, $m[1]) -eq 2) {
        break
    }
}
