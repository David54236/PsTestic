### System tests
#################################
Function Test-PSSessionIsElevated {
    <#
    .SYNOPSIS
        Checks if a session is elevated

    .NOTES
        Name: Test-PSSessionIsElevated
        Author: David Porcher
        Version: 1.0
        DateCreated: 18.10.2021

    .EXAMPLE
        Test-PSSessionIsElevated
        Test-PSSessionIsElevated -WindowsPrincipal
    #>

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 0
        )]
        [Security.Principal.WindowsPrincipal] $WindowsPrincipal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    )

    BEGIN {
        [string] $builtInAdminRoleName = "Administrator";
    }

    PROCESS {
        if ($WindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] $builtInAdminRoleName)) {
            return $true;
        }
        else {
            return $false;
        }
    }

    END {}
}
Function Test-CommandExists {
    <#
    .SYNOPSIS
        Checks if the maschine can run the given command

    .NOTES
        Name: Test-CommandExists
        Author: David Porcher
        Version: 1.0
        DateCreated: 18.10.2021

    .EXAMPLE
        Test-CommandExists -command "ping"

    #>

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 0
        )]
        [string] $command
    )

    BEGIN {
        [string] $errorAction = "stop";
    }

    PROCESS {
        try {
            if (Get-Command $command -ErrorAction $errorAction) {
                return $true;
            }
        }
        Catch {
            return $false;
        }
    }

    END {}
}

### Network tests
#################################
Function Test-NetAdapterIsUp {
    <#
    .SYNOPSIS
        Checks if at least one Network Adapter is connected to a network

    .NOTES
        Name: Test-NetAdapterIsUp
        Author: David Porcher
        Version: 1.0
        DateCreated: 18.10.2021

    .EXAMPLE
        Test-NetAdapterIsUp

    #>

    [CmdletBinding()]
    param()

    BEGIN {
        [string] $statusUp = "Up";
    }

    PROCESS {
        foreach ($adapter in Get-NetAdapter) {
            if ($adapter.status -eq $statusUp) {
                return $true;
            }
        }
        return $false;
    }

    END {}
}
Function Test-NetIsMetered {
    <#
    .SYNOPSIS
        Checks if the network connection is metered

    .NOTES
        Name: Test-NetIsMetered
        Author: David Porcher
        Version: 1.0
        DateCreated: 18.10.2021

    .EXAMPLE
        Test-NetIsMetered

    #>

    [CmdletBinding()]
    param()

    BEGIN {
        [string] $networkCostTypeUnrestricted = "Unrestricted";
        [string] $networkCostTypeUnknown = "Unknown"; # Default value in Windows Server 2016
    }

    PROCESS {
        if (Test-NetAdapterIsUp) {
            [void][Windows.Networking.Connectivity.NetworkInformation, Windows, ContentType = WindowsRuntime];
            $cost = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile().GetConnectionCost();
            return  $cost.ApproachingDataLimit -or
            $cost.OverDataLimit -or
            $cost.Roaming -or
            $cost.BackgroundDataUsageRestricted -or
            (($cost.NetworkCostType -ne $networkCostTypeUnrestricted) -and
             ($cost.NetworkCostType -ne $networkCostTypeUnknown)
            );
        }
        return $false;
    }

    END {}
}