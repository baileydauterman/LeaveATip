function Write-Box {
    param (
        [string]
        $Text,
        # Number of characters to pad content on each side of the box
        [int]
        $HorizontalPadding = 1,
        [int]
        $VerticalPadding = 0
    )

    $corners = @{
        TopRight    = [char]0x256E # ╮
        TopLeft     = [char]0x256D # ╭
        BottomRight = [char]0x256F # ╯
        BottomLeft  = [char]0x2570 # ╰
    }
    
    $lines = @{
        Horizontal = [char]0x2500 # ─
        Vertical   = [char]0x2502 # │
    }
    
    $len = $Text.Length
    $width = [Console]::WindowWidth
    $outsidePadding = $HorizontalPadding * 2

    if ($len + $outsidePadding -gt $width) {
        $contentWidthPadding = $width - $outsidePadding + 2
    }
    else {
        $contentWidthPadding = $len + $outsidePadding + 2
    }

    
    $lineFormat = "{0}{1}{2}"
    $Text = "$(" " * $HorizontalPadding) $Text $(" " * $HorizontalPadding)"

    if ($VerticalPadding -gt 0) {
        $VertPaddingText = " " * $Text.Length
    }

    $retVals = @()

    $top = $lineFormat -f $corners.TopLeft, ([string]$lines.Horizontal * $contentWidthPadding), $corners.TopRight
    $line = $lineFormat -f $lines.Vertical, $Text, $lines.Vertical
    $bottom = $lineFormat -f $corners.BottomLeft, ([string]$lines.Horizontal * $contentWidthPadding), $corners.BottomRight

    $retVals += $top
    for ($i = 0; $i -lt $VerticalPadding; $i++) {
        $retVals += ($lineFormat -f $lines.Vertical, $VertPaddingText, $lines.Vertical)
    }
    $retVals += $line
    for ($i = 0; $i -lt $VerticalPadding; $i++) {
        $retVals += ($lineFormat -f $lines.Vertical, $VertPaddingText, $lines.Vertical)
    }
    $retVals += $bottom

    return $retVals
}

function Write-TipAsk {
    param(
        [int]
        $LeftPercentage = 15,
        [int]
        $MiddlePercentage = 20,
        [int]
        $RightPercentage = 25
    )

    $left = Write-Box -Text "$LeftPercentage%" -VerticalPadding 2 -HorizontalPadding 9
    $middle = Write-Box -Text "$MiddlePercentage%" -VerticalPadding 2 -HorizontalPadding 9
    $right = Write-Box -Text "$RightPercentage%" -VerticalPadding 2 -HorizontalPadding 9

    $joined = @()

    for ($i = 0; $i -lt $left.Count; $i++) {
        $joined += "$($left[$i]) $($middle[$i]) $($right[$i])"
    }

    $customLength = $joined[0].Length - 4
    $custStr = "Custom".PadLeft($customLength / 2).PadRight($customLength)
    $latStr = "Leave a tip?".PadLeft(($customLength+12) / 2).PadRight($customLength)


    $joined += @(Write-Box -Text $custStr -VerticalPadding 2 -HorizontalPadding 0)

    Write-Host "`n`n$latStr`n`n"
    Write-Host ($joined | Out-String) -BackgroundColor Blue
}
