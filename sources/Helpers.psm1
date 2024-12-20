using namespace System;

class ConsoleLogHelper
{
	[ConsoleColor] $colorBorder = [ConsoleColor]::White;
	[ConsoleColor] $colorFail = [ConsoleColor]::Red;
	[ConsoleColor] $colorMessage = [ConsoleColor]::Blue;
	[ConsoleColor] $colorSuccess = [ConsoleColor]::Green;

	# pad right value for message allignment
	[Int32] $messagePadRightWidth;

	LogHelper (
		[Int32] $messagePadRightWidth
	)
	{
		$this.messagePadRightWidth = $messagePadRightWidth;
	}

	[Void] OperationBegin(
		[String] $message
	)
	{
		Write-Host '| ' -ForegroundColor $this.colorBorder -NoNewline;

		Write-Host $message.PadRight($this.messagePadRightWidth) -ForegroundColor $this.colorMessage -NoNewline;

		Write-Host '| ' -ForegroundColor $this.colorBorder -NoNewline;
	}

	[Void] OperationEnd(
		[Boolean] $status,
		[String] $message = $null
	)
	{
		if ($status)
		{
			Write-Host 'Success'.PadRight(8) -ForegroundColor Green -NoNewline;
		}
		else
		{
			Write-Host 'Fail'.PadRight(8) -ForegroundColor Red -NoNewline;
		}

		if ([String]::IsNullOrWhiteSpace($message))
		{
			Write-Host ' |' -ForegroundColor White;
		}
		else
		{
			Write-Host ' | ' -ForegroundColor White -NoNewline;

			Write-Host $message -ForegroundColor Green;
		}
	}

	[Void] OperationEndSuccess(
		[Nullable[String]] $message = $null
	)
	{
		$this.OperationEnd($true, $message);
	}
}

[OutputType[ConsoleLogHelper]]
function New-ConsoleLogHelper
{
	param
	(
		[Parameter(Mandatory = $true)] [Int32] $messagePadRightWidth
	)
	process
	{
		return [ConsoleLogHelper]::new($messagePadRightWidth);
	}
}

Export-ModuleMember -Function New-ConsoleLogHelper;