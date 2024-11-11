function Get-Repeated {
    param(
        [object]
        $Value,
        [int]
        $Count,
        [switch]
        $AsString
    )

    if ($AsString) {
        [System.Linq.Enumerable]::Repeat($Value, $Count) -join ""
    }
    else {
        [System.Linq.Enumerable]::Repeat($Value, $Count)
    }
}
function Write-Box {
    param (
        [string]
        $Text,
        # Number of characters to pad content on each side of the box
        [int]
        $HorizontalPadding = 1,
        # Number of lines to pad above and below the box
        [int]
        $VerticalPadding = 0,
        # Make the box take up the full terminal screen
        [switch]
        $FullScreen
    )

    begin {
        $BoxingLines = @{
            TopLeft     = [char]0x256D # ╭
            BottomLeft  = [char]0x2570 # ╰
            TopRight    = [char]0x256E # ╮
            BottomRight = [char]0x256F # ╯
            Horizontal = [char]0x2500 # ─
            Vertical   = [char]0x2502 # │
        }

        $lineFormat = "{0}{1}{2}"
        $padding = $HorizontalPadding * 2
    
        $splitString = $Text.Split("`n")
        # Length of longest string + sum of horizontal padding
        $contentWidth = ($splitString | Sort-Object | Select-Object -First 1).Length + $padding
        $topBottomLine = Get-Repeated -Value $BoxingLines.Horizontal -Count $contentWidth -AsString

        # return top line
        $lineFormat -f $BoxingLines.TopLeft, $topBottomLine, $BoxingLines.TopRight
    }
    process {
        if ($VerticalPadding -gt 0) {
            $PaddedVerticalLine = $lineFormat -f $BoxingLines.Vertical, "".PadLeft($contentWidth), $BoxingLines.Vertical
        }

        Get-Repeated $PaddedVerticalLine $VerticalPadding

        $horizontalPaddingText = "".PadLeft($HorizontalPadding)

        foreach ($line in $splitString) {
            $paddedLine = $lineFormat -f $horizontalPaddingText, $line, $horizontalPaddingText
            $lineFormat -f $BoxingLines.Vertical, $paddedLine.PadLeft(($contentWidth -2) / 2).PadRight($contentWidth), $BoxingLines.Vertical
        }
    
        Get-Repeated $PaddedVerticalLine $VerticalPadding
    }

    end {
        $lineFormat -f $BoxingLines.BottomLeft, $topBottomLine, $BoxingLines.BottomRight
    }
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

    $totalLineLength = $joined[0].Length - 4
    $custStr = "Custom".PadLeft($totalLineLength / 2).PadRight($totalLineLength)
    $latStr = "Leave a tip?".PadLeft(($totalLineLength+12) / 2).PadRight($totalLineLength)


    $joined += @(Write-Box -Text $custStr -VerticalPadding 2)

    Write-Host "`n`n$latStr`n`n"
    Write-Host ($joined | Out-String) -BackgroundColor Blue
}
