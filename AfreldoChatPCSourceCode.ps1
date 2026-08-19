Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$global:firebaseUrl = ""

$modernFont = New-Object System.Drawing.Font("Segoe UI", 9.5)
$boldFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

# Helper Function to Create Rounded Corners for Forms
function Set-RoundedForm($form, $radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $rect = New-Object System.Drawing.Rectangle(0, 0, $form.Width, $form.Height)
    $arc = New-Object System.Drawing.Rectangle($rect.X, $rect.Y, $radius, $radius)
    
    $path.AddArc($arc, 180, 90)
    $arc.X = $rect.Right - $radius
    $path.AddArc($arc, 270, 90)
    $arc.Y = $rect.Bottom - $radius
    $path.AddArc($arc, 0, 90)
    $arc.X = $rect.Left
    $path.AddArc($arc, 90, 90)
    
    $path.CloseFigure()
    $form.Region = New-Object System.Drawing.Region($path)
}

# Helper Function to Clean and Format Firebase URL safely
function Get-FormattedFirebaseUrl($rawUrl) {
    if ([string]::IsNullOrWhiteSpace($rawUrl)) { return "" }
    $cleanUrl = $rawUrl.Trim()
    
    if (-not $cleanUrl.EndsWith(".json")) {
        if ($cleanUrl.EndsWith("/")) {
            $cleanUrl = "${cleanUrl}messages.json"
        } else {
            $cleanUrl = "${cleanUrl}/messages.json"
        }
    }
    return $cleanUrl
}

$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "Floating Chat Control"
$mainForm.Size = New-Object System.Drawing.Size(340, 240)
$mainForm.StartPosition = "CenterScreen"
$mainForm.FormBorderStyle = "None"
$mainForm.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)

$pnlMainHeader = New-Object System.Windows.Forms.Panel
$pnlMainHeader.Size = New-Object System.Drawing.Size(340, 35)
$pnlMainHeader.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)

$lblMainTitle = New-Object System.Windows.Forms.Label
$lblMainTitle.Text = "  Control Center"
$lblMainTitle.Font = $modernFont
$lblMainTitle.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
$lblMainTitle.Location = New-Object System.Drawing.Point(5, 8)
$lblMainTitle.Size = New-Object System.Drawing.Size(240, 20)

$btnCloseMain = New-Object System.Windows.Forms.Button
$btnCloseMain.Text = "✕"
$btnCloseMain.Font = $modernFont
$btnCloseMain.Size = New-Object System.Drawing.Size(35, 30)
$btnCloseMain.Location = New-Object System.Drawing.Point(300, 2)
$btnCloseMain.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnCloseMain.FlatAppearance.BorderSize = 0
$btnCloseMain.ForeColor = [System.Drawing.Color]::White
$btnCloseMain.BackColor = [System.Drawing.Color]::Transparent
$btnCloseMain.Add_Click({
    Close-FloatingChatSystem
    $mainForm.Close()
})

$pnlMainHeader.Controls.Add($lblMainTitle)
$pnlMainHeader.Controls.Add($btnCloseMain)

$script:isMainDragging = $false
$script:mainMouseOffset = $null
$pnlMainHeader.Add_MouseDown({
    param($s, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isMainDragging = $true
        $script:mainMouseOffset = $e.Location
    }
})
$pnlMainHeader.Add_MouseMove({
    param($s, $e)
    if ($script:isMainDragging) {
        $currPos = [System.Windows.Forms.Cursor]::Position
        $mainForm.Location = New-Object System.Drawing.Point(($currPos.X - $script:mainMouseOffset.X), ($currPos.Y - $script:mainMouseOffset.Y))
    }
})
$pnlMainHeader.Add_MouseUp({ $script:isMainDragging = $false })

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Status: Floating Chat Inactive"
$lblStatus.Location = New-Object System.Drawing.Point(20, 48)
$lblStatus.Size = New-Object System.Drawing.Size(300, 20)
$lblStatus.Font = $modernFont
$lblStatus.ForeColor = [System.Drawing.Color]::DarkGray

$lblCredit = New-Object System.Windows.Forms.Label
$lblCredit.Text = "Created By Afreldo, Visit YouTube @BibzS4mpwats"
$lblCredit.Location = New-Object System.Drawing.Point(20, 68)
$lblCredit.Size = New-Object System.Drawing.Size(300, 20)
$lblCredit.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$lblCredit.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)

$btnActivate = New-Object System.Windows.Forms.Button
$btnActivate.Location = New-Object System.Drawing.Point(20, 80)
$btnActivate.Size = New-Object System.Drawing.Size(295, 42)
$btnActivate.Text = "Activate Floating Chat"
$btnActivate.Font = $boldFont
$btnActivate.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$btnActivate.ForeColor = [System.Drawing.Color]::White
$btnActivate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnActivate.FlatAppearance.BorderSize = 0

$btnDeactivate = New-Object System.Windows.Forms.Button
$btnDeactivate.Location = New-Object System.Drawing.Point(20, 130)
$btnDeactivate.Size = New-Object System.Drawing.Size(295, 35)
$btnDeactivate.Text = "Deactivate Floating Chat"
$btnDeactivate.Font = $modernFont
$btnDeactivate.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$btnDeactivate.ForeColor = [System.Drawing.Color]::White
$btnDeactivate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnDeactivate.FlatAppearance.BorderSize = 0
$btnDeactivate.Enabled = $false

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Location = New-Object System.Drawing.Point(20, 175)
$btnExit.Size = New-Object System.Drawing.Size(295, 30)
$btnExit.Text = "Exit Application"
$btnExit.Font = $modernFont
$btnExit.BackColor = [System.Drawing.Color]::FromArgb(160, 40, 40)
$btnExit.ForeColor = [System.Drawing.Color]::White
$btnExit.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnExit.FlatAppearance.BorderSize = 0

$mainForm.Controls.Add($pnlMainHeader)
$mainForm.Controls.Add($lblStatus)
$mainForm.Controls.Add($lblCredit)
$mainForm.Controls.Add($btnActivate)
$mainForm.Controls.Add($btnDeactivate)
$mainForm.Controls.Add($btnExit)

$mainForm.Add_Load({
    Set-RoundedForm $mainForm 12
})

$global:floatingBtn = $null
$global:chatWindow = $null
$global:txtChatBox = $null
$global:txtInput = $null
$global:chatTimer = $null
$global:isChatOpen = $false

# Function to Fetch Messages from Firebase
function Get-FirebaseMessages {
    if ([string]::IsNullOrWhiteSpace($global:firebaseUrl)) { return "Firebase URL not set." }
    try {
        $response = Invoke-RestMethod -Uri $global:firebaseUrl -Method Get -TimeoutSec 3
        $output = ""
        if ($response) {
            foreach ($key in $response.psobject.properties.name) {
                $msg = $response.$key
                $output += "$($msg.sender): $($msg.message)`r`n"
            }
        }
        return $output
    } catch {
        return "Connection Failed"
    }
}

# Function to Send Message to Firebase
function Send-FirebaseMessage($text) {
    if ([string]::IsNullOrWhiteSpace($text) -or [string]::IsNullOrWhiteSpace($global:firebaseUrl)) { return }
    try {
        $timestamp = [Math]::Floor([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())
        $body = @{ 
            sender = "Player"
            message = $text 
            timestamp = $timestamp
        } | ConvertTo-Json
        
        Invoke-RestMethod -Uri $global:firebaseUrl -Method Post -Body $body -ContentType "application/json" | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to send message: $_", "Firebase Error")
    }
}

# Activate Button with URL Setup Dialog
$btnActivate.Add_Click({
    $inputForm = New-Object System.Windows.Forms.Form
    $inputForm.Text = "Setup Firebase Database URL"
    $inputForm.Size = New-Object System.Drawing.Size(430, 200)
    $inputForm.StartPosition = "CenterScreen"
    $inputForm.FormBorderStyle = "FixedDialog"
    $inputForm.MaximizeBox = $false
    $inputForm.MinimizeBox = $false
    $inputForm.BackColor = [System.Drawing.Color]::FromArgb(32, 32, 32)
    $inputForm.ForeColor = [System.Drawing.Color]::White

    $lblInstruct = New-Object System.Windows.Forms.Label
    $lblInstruct.Text = "Masukkan link Firebase (Contoh: https://xxx-default-rtdb.asia-southeast1.firebasedatabase.app/)"
    $lblInstruct.Location = New-Object System.Drawing.Point(15, 15)
    $lblInstruct.Size = New-Object System.Drawing.Size(390, 40)
    $lblInstruct.Font = $modernFont

    $txtUrlInput = New-Object System.Windows.Forms.TextBox
    $txtUrlInput.Location = New-Object System.Drawing.Point(15, 60)
    $txtUrlInput.Size = New-Object System.Drawing.Size(390, 25)
    $txtUrlInput.Font = $modernFont
    $txtUrlInput.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $txtUrlInput.ForeColor = [System.Drawing.Color]::White
    if ($global:firebaseUrl) { 
        # Tampilkan tanpa akhiran .json jika ingin bersih di textbox, atau biarkan jika sudah diset
        $txtUrlInput.Text = $global:firebaseUrl -replace "/messages\.json$", "" 
    }

    $btnSaveUrl = New-Object System.Windows.Forms.Button
    $btnSaveUrl.Text = "Start Floating Chat"
    $btnSaveUrl.Location = New-Object System.Drawing.Point(250, 110)
    $btnSaveUrl.Size = New-Object System.Drawing.Size(155, 32)
    $btnSaveUrl.Font = $boldFont
    $btnSaveUrl.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    $btnSaveUrl.ForeColor = [System.Drawing.Color]::White
    $btnSaveUrl.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnSaveUrl.FlatAppearance.BorderSize = 0

    $btnSaveUrl.Add_Click({
        $enteredUrl = $txtUrlInput.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($enteredUrl)) {
            [System.Windows.Forms.MessageBox]::Show("Link Firebase tidak boleh kosong!", "Peringatan", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        # Format URL secara otomatis agar kompatibel dengan REST API (.json)
        $global:firebaseUrl = Get-FormattedFirebaseUrl $enteredUrl
        
        $inputForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $inputForm.Close()
    })

    $inputForm.Controls.Add($lblInstruct)
    $inputForm.Controls.Add($txtUrlInput)
    $inputForm.Controls.Add($btnSaveUrl)

    $result = $inputForm.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        Show-FloatingButton
        $btnActivate.Enabled = $false
        $btnDeactivate.Enabled = $true
        $btnActivate.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
        $btnDeactivate.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
        $lblStatus.Text = "Status: Floating Chat Turned ON"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
        $mainForm.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
    }
})

# Deactivate Button
$btnDeactivate.Add_Click({
    Close-FloatingChatSystem
    $btnActivate.Enabled = $true
    $btnDeactivate.Enabled = $false
    $btnActivate.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    $btnActivate.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $lblStatus.Text = "Status: Floating Chat Turned OFF"
    $lblStatus.ForeColor = [System.Drawing.Color]::DarkGray
})

# Exit Button
$btnExit.Add_Click({
    Close-FloatingChatSystem
    $mainForm.Close()
})

# 2. Create Perfect Circle Floating Button
function Show-FloatingButton {
    if ($global:floatingBtn -and !$global:floatingBtn.IsDisposed) { return }

    $global:floatingBtn = New-Object System.Windows.Forms.Form
    $global:floatingBtn.Size = New-Object System.Drawing.Size(60, 60)
    $global:floatingBtn.StartPosition = "Manual"
    $global:floatingBtn.Location = New-Object System.Drawing.Point(100, 100)
    $global:floatingBtn.TopMost = $true
    $global:floatingBtn.FormBorderStyle = "None"
    $global:floatingBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)

    # Perfect Circle Shape
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(0, 0, 60, 60)
    $global:floatingBtn.Region = New-Object System.Drawing.Region($path)

    # Draw Vector Chat Bubble Icon
    $global:floatingBtn.add_Paint({
        param($sender, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $bubbleRect = New-Object System.Drawing.Rectangle(14, 15, 32, 24)
        $g.FillEllipse($brush, $bubbleRect)
        
        $points = [System.Drawing.Point[]]@(
            (New-Object System.Drawing.Point(22, 37)),
            (New-Object System.Drawing.Point(18, 45)),
            (New-Object System.Drawing.Point(28, 38))
        )
        $g.FillPolygon($brush, $points)
        
        $dotBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 120, 212))
        $g.FillEllipse($dotBrush, 21, 24, 4, 4)
        $g.FillEllipse($dotBrush, 28, 24, 4, 4)
        $g.FillEllipse($dotBrush, 35, 24, 4, 4)
    })

    $global:floatingBtn.Add_Click({
        Toggle-ChatWindow
    })

    $script:isDragging = $false
    $script:mouseOffset = $null

    $global:floatingBtn.Add_MouseDown({
        param($sender, $e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            $script:isDragging = $true
            $script:mouseOffset = $e.Location
        }
    })

    $global:floatingBtn.Add_MouseMove({
        param($sender, $e)
        if ($script:isDragging) {
            $currentPos = [System.Windows.Forms.Cursor]::Position
            $global:floatingBtn.Location = New-Object System.Drawing.Point(
                ($currentPos.X - $script:mouseOffset.X),
                ($currentPos.Y - $script:mouseOffset.Y)
            )
        }
    })

    $global:floatingBtn.Add_MouseUp({ $script:isDragging = $false })

    [void]$global:floatingBtn.Show()
}

function Toggle-ChatWindow {
    if ($global:isChatOpen) {
        if ($global:chatWindow -and !$global:chatWindow.IsDisposed) { $global:chatWindow.Close() }
        $global:isChatOpen = $false
        return
    }

    if ($null -eq $global:floatingBtn) { return }

    $global:chatWindow = New-Object System.Windows.Forms.Form
    $global:chatWindow.Size = New-Object System.Drawing.Size(320, 420)
    $global:chatWindow.StartPosition = "Manual"
    
    $btnPos = $global:floatingBtn.Location
    $global:chatWindow.Location = New-Object System.Drawing.Point(($btnPos.X + 70), $btnPos.Y)
    $global:chatWindow.TopMost = $true
    $global:chatWindow.FormBorderStyle = "None"
    $global:chatWindow.BackColor = [System.Drawing.Color]::FromArgb(32, 32, 32)

    # Custom Chat Header Panel
    $pnlHeader = New-Object System.Windows.Forms.Panel
    $pnlHeader.Size = New-Object System.Drawing.Size(320, 35)
    $pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "  Chat"
    $lblTitle.Font = $modernFont
    $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $lblTitle.Location = New-Object System.Drawing.Point(5, 8)
    $lblTitle.Size = New-Object System.Drawing.Size(240, 20)

    $btnCloseChat = New-Object System.Windows.Forms.Button
    $btnCloseChat.Text = "✕"
    $btnCloseChat.Font = $modernFont
    $btnCloseChat.Size = New-Object System.Drawing.Size(35, 30)
    $btnCloseChat.Location = New-Object System.Drawing.Point(280, 2)
    $btnCloseChat.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnCloseChat.FlatAppearance.BorderSize = 0
    $btnCloseChat.ForeColor = [System.Drawing.Color]::White
    $btnCloseChat.BackColor = [System.Drawing.Color]::Transparent
    $btnCloseChat.Add_Click({
        $global:chatWindow.Close()
    })

    $pnlHeader.Controls.Add($lblTitle)
    $pnlHeader.Controls.Add($btnCloseChat)

    $script:isChatDragging = $false
    $script:chatMouseOffset = $null
    $pnlHeader.Add_MouseDown({
        param($s, $e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            $script:isChatDragging = $true
            $script:chatMouseOffset = $e.Location
        }
    })
    $pnlHeader.Add_MouseMove({
        param($s, $e)
        if ($script:isChatDragging) {
            $currPos = [System.Windows.Forms.Cursor]::Position
            $global:chatWindow.Location = New-Object System.Drawing.Point(($currPos.X - $script:chatMouseOffset.X), ($currPos.Y - $script:chatMouseOffset.Y))
        }
    })
    $pnlHeader.Add_MouseUp({ $script:isChatDragging = $false })

    # Message Display Box
    $global:txtChatBox = New-Object System.Windows.Forms.TextBox
    $global:txtChatBox.Multiline = $true
    $global:txtChatBox.ReadOnly = $true
    $global:txtChatBox.ScrollBars = "Vertical"
    $global:txtChatBox.Size = New-Object System.Drawing.Size(296, 305)
    $global:txtChatBox.Location = New-Object System.Drawing.Point(12, 45)
    $global:txtChatBox.Font = $modernFont
    $global:txtChatBox.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
    $global:txtChatBox.ForeColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
    $global:txtChatBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $global:txtChatBox.Text = Get-FirebaseMessages

    # Text Input Box
    $global:txtInput = New-Object System.Windows.Forms.TextBox
    $global:txtInput.Size = New-Object System.Drawing.Size(215, 26)
    $global:txtInput.Location = New-Object System.Drawing.Point(12, 368)
    $global:txtInput.Font = $modernFont
    $global:txtInput.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $global:txtInput.ForeColor = [System.Drawing.Color]::White
    $global:txtInput.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

    # Send Button
    $btnSend = New-Object System.Windows.Forms.Button
    $btnSend.Text = "Send"
    $btnSend.Size = New-Object System.Drawing.Size(75, 28)
    $btnSend.Location = New-Object System.Drawing.Point(233, 367)
    $btnSend.Font = $modernFont
    $btnSend.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    $btnSend.ForeColor = [System.Drawing.Color]::White
    $btnSend.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnSend.FlatAppearance.BorderSize = 0

    $global:chatTimer = New-Object System.Windows.Forms.Timer
    $global:chatTimer.Interval = 2000
    $global:chatTimer.Add_Tick({
        if ($global:txtChatBox -and !$global:txtChatBox.IsDisposed) {
            $global:txtChatBox.Text = Get-FirebaseMessages
            $global:txtChatBox.SelectionStart = $global:txtChatBox.Text.Length
            $global:txtChatBox.ScrollToCaret()
        }
    })
    $global:chatTimer.Start()

    $btnSend.Add_Click({
        Send-FirebaseMessage $global:txtInput.Text
        $global:txtInput.Text = ""
        Start-Sleep -Milliseconds 400
        if ($global:txtChatBox -and !$global:txtChatBox.IsDisposed) {
            $global:txtChatBox.Text = Get-FirebaseMessages
        }
    })

    $global:txtInput.Add_KeyDown({
        param($sender, $e)
        if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            Send-FirebaseMessage $global:txtInput.Text
            $global:txtInput.Text = ""
            Start-Sleep -Milliseconds 400
            if ($global:txtChatBox -and !$global:txtChatBox.IsDisposed) {
                $global:txtChatBox.Text = Get-FirebaseMessages
            }
            $e.SuppressKeyPress = $true
        }
    })

    $global:chatWindow.Add_FormClosed({
        if ($global:chatTimer) {
            $global:chatTimer.Stop()
        }
        $global:isChatOpen = $false
    })

    $global:chatWindow.Add_Load({
        Set-RoundedForm $global:chatWindow 10
    })

    $global:chatWindow.Controls.Add($pnlHeader)
    $global:chatWindow.Controls.Add($global:txtChatBox)
    $global:chatWindow.Controls.Add($global:txtInput)
    $global:chatWindow.Controls.Add($btnSend)

    $global:isChatOpen = $true
    [void]$global:chatWindow.Show()
}

# Cleanup Floating System Function
function Close-FloatingChatSystem {
    if ($global:chatTimer) {
        $global:chatTimer.Stop()
    }
    if ($global:chatWindow -and !$global:chatWindow.IsDisposed) {
        $global:chatWindow.Close()
    }
    if ($global:floatingBtn -and !$global:floatingBtn.IsDisposed) {
        $global:floatingBtn.Close()
    }
    $global:isChatOpen = $false
}

[void]$mainForm.ShowDialog()