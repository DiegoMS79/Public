
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore

Connect-VIServer vcenter.pjc.local


ForEach($VM in get-vm | Where-Object {$_.Name -like "ContainerHost-*" }) {
    echo $VM.name 
    echo "Removing Snapshot..." (Get-Snapshot -VM $VM).Name

    Get-Snapshot -VM $VM | Remove-Snapshot -Confirm:$false 

    echo "Creating New Snapshot..."

    New-Snapshot -VM $VM.name -Name (get-date).ToString() -Memory:$true -Quiesce:$true -RunAsync:$true
}

