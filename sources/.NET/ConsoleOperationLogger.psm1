using namespace System;

function New-ConsoleOperationLogger
{
	<#
	.SYNOPSIS
		Create a new instance of ConsoleOperationLogger class.
	.DESCRIPTION
		Helps use console for loggin.
	.PARAMETER padWidthOperation
		Message column padding.
	.OUTPUTS
		Instance of ConsoleOperationLogger class.
	.NOTES
		Copyright © 2024 Stas Sultanov.
	#>
	[OutputType([ConsoleOperationLogger])]
	param
	(
		[Parameter(Mandatory = $true)] [Int32] $padWidthOperation
	)
	process
	{
		$result = [ConsoleOperationLogger]::new($padWidthOperation);

		return $result;
	}
}

Export-ModuleMember -Function New-ConsoleOperationLogger;

class ConsoleOperationLogger
{
	[ConsoleColor] $colorTabelBorder = [ConsoleColor]::Blue;
	[ConsoleColor] $colorTabelColumnName = [ConsoleColor]::Yellow;
	[ConsoleColor] $colorDetails = [ConsoleColor]::Cyan;
	[ConsoleColor] $colorId = [ConsoleColor]::Magenta;
	[ConsoleColor] $colorOperation = [ConsoleColor]::White;
	[ConsoleColor] $colorStatusFail = [ConsoleColor]::Red;
	[ConsoleColor] $colorStatusSuccess = [ConsoleColor]::Green;

	hidden [String] $columnNameDetails = 'Details';
	hidden [String] $columnNameId = 'Id';
	hidden [String] $columnNameOperation = 'Operation';
	hidden [String] $columnNameStatus = 'Status';
	hidden [String] $columnNameTime = 'Time, ms';

	hidden [DateTime] $operationBeginTime;
	hidden [DateTime] $operationEndTime;
	hidden [Int32] $operationCounter = 0;

	hidden [Int32] $padWidthId = 2;
	hidden [Int32] $padWidthOperation;
	hidden [Int32] $padWidthStatus = 7;
	hidden [Int32] $padWidthTime = 8;

	hidden [String] $tableFillDetails;
	hidden [String] $tableFillId;
	hidden [String] $tableFillOperation;
	hidden [String] $tableFillStatus;
	hidden [String] $tableFillTime;

	ConsoleOperationLogger (
		[Int32] $padWidthOperation
	)
	{
		$this.padWidthOperation = $padWidthOperation;

		$this.tableFillDetails = '━' * 10;
		$this.tableFillId = '━' * ($this.padWidthId + 2);
		$this.tableFillOperation = '━' * ($this.padWidthOperation + 2);
		$this.tableFillStatus = '━' * ($this.padWidthStatus + 2);
		$this.tableFillTime = '━' * ($this.padWidthTime + 2);
	}

	[Void] OperationBegin(
		[String] $operation
	)
	{
		# increment operation counter
		$this.operationCounter++;

		# write row begin
		$this.WriteRowBegin(
			$this.operationCounter.ToString().PadLeft($this.padWidthId),
			$this.colorId,
			$operation.PadRight($this.padWidthOperation),
			$this.colorOperation
		);

		# set begin time
		$this.operationBeginTime = [DateTime]::UtcNow;
	}

	[Void] OperationEnd(
		[Boolean] $success,
		[String] $details
	)
	{
		# set begin time
		$this.operationEndTime = [DateTime]::UtcNow;

		# calculate opretaion time
		$operationTime = [Int32] ($this.operationEndTime.Subtract($this.operationBeginTime).TotalMilliseconds);

		# status
		$status = ($success ? 'Success' : 'Fail').PadRight($this.padWidthStatus);

		$statusColor = $success ? $this.colorStatusSuccess : $this.colorStatusFail;

		$this.WriteRowEnd(
			$status,
			$statusColor,
			$operationTime.ToString().PadLeft($this.padWidthTime),
			$this.colorOperation,
			$details,
			$this.colorDetails
		);
	}

	[Void] OperationEnd(
		[Boolean] $status
	)
	{
		$this.OperationEnd($status, $null);
	}

	[Void] OperationEndSuccess(
	)
	{
		$this.OperationEnd($true, $null);
	}

	[Void] OperationEndSuccess(
		[String] $message
	)
	{
		$this.OperationEnd($true, $message);
	}

	[Void] ProcessBegin(
	)
	{
		$this.operationCounter = 0;

		# table head top

		$tableHeadTop = '┏' + $this.tableFillId + '┳' + $this.tableFillOperation + '┳' + $this.tableFillStatus + '┳' + $this.tableFillTime + '┳' + $this.tableFillDetails;

		Write-Host $tableHeadTop -ForegroundColor $this.colorTabelBorder;

		# teble column names
		$this.WriteRowBegin(
			$this.columnNameId.PadLeft($this.padWidthId),
			$this.colorTabelColumnName,
			$this.columnNameOperation.PadRight($this.padWidthOperation),
			$this.colorOperation
		);

		$this.WriteRowEnd(
			$this.columnNameStatus.PadRight($this.padWidthStatus),
			$this.colorTabelColumnName,
			$this.columnNameTime.PadRight($this.padWidthTime),
			$this.colorTabelColumnName,
			$this.columnNameDetails,
			$this.colorTabelColumnName
		);

		# table head bottom

		$tableHeadBottom = '┣' + $this.tableFillId + '╋' + $this.tableFillOperation + '╋' + $this.tableFillStatus + '╋' + $this.tableFillTime + '╋' + $this.tableFillDetails;

		Write-Host $tableHeadBottom -ForegroundColor $this.colorTabelBorder;
	}

	[Void] ProcessEnd(
	)
	{
		$tableFootBottom = '┗' + $this.tableFillId + '┻' + $this.tableFillOperation + '┻' + $this.tableFillStatus + '┻' + $this.tableFillTime + '┻' + $this.tableFillDetails;

		Write-Host $tableFootBottom -ForegroundColor $this.colorTabelBorder;
	}

	hidden [Void] WriteRowBegin(
		[String] $id,
		[ConsoleColor] $idColor,
		[String] $message,
		[ConsoleColor] $messageColor
	)
	{
		Write-Host '┃ ' -ForegroundColor $this.colorTabelBorder -NoNewline;

		Write-Host $id -ForegroundColor $idColor -NoNewline;

		Write-Host ' ┃ ' -ForegroundColor $this.colorTabelBorder -NoNewline;

		Write-Host $message -ForegroundColor $messageColor -NoNewline;

		Write-Host ' ┃ ' -ForegroundColor $this.colorTabelBorder -NoNewline;
	}

	[Void] WriteRowEnd(
		[String] $status,
		[ConsoleColor] $statusColor,
		[String] $duration,
		[ConsoleColor] $durationColor,
		[String] $details,
		[ConsoleColor] $detailsColor
	)
	{
		Write-Host $status -ForegroundColor $statusColor -NoNewline;

		Write-Host ' ┃ ' -ForegroundColor $this.colorTabelBorder -NoNewline;

		Write-Host $duration -ForegroundColor $durationColor -NoNewline;

		Write-Host ' ┃ ' -ForegroundColor $this.colorTabelBorder -NoNewline;

		Write-Host $details -ForegroundColor $detailsColor;
	}
}