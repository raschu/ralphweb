<?php
	// Löst die Renntitel für die Diagramme auf
	function resolve_race_title($race_type)
	{
		switch ($race_type)
		{
			case "beaq":
				$race = "Beaver Creek Qualifikation";
				break;
			case "bear":
				$race = "Beaver Creek Rennen";
				break;
			case "groq":
				$race = "Groeden Qualifikation";
				break;
			case "gror":
				$race = "Groeden Rennen";
				break;
			case "borq":
				$race = "Bormio Qualifikation";
				break;
			case "borr":
				$race = "Bormio Rennen";
				break;
			case "wenq":
				$race = "Wengen Qualifikation";
				break;
			case "wenr":
				$race = "Wengen Rennen";
				break;
			case "kitq":
				$race = "Kitzbuehl Qualifikation";
				break;
			case "kitr":
				$race = "Kitzbuehl Rennen";
				break;
			case "garq":
				$race = "Garmisch Qualifikation";
				break;
			case "garr":
				$race = "Garmisch Rennen";
				break;	
			case "vadq":
				$race = "Val d Isere Qualifikation";
				break;
			case "vadr":
				$race = "Val d Isere Rennen";
				break;
			case "schq":
				$race = "Schladming Qualifikation";
				break;
			case "schr":
				$race = "Schladming Rennen";
				break;
			case "socq":
				$race = "Sochi Qualifikation";
				break;
			case "socr":
				$race = "Sochi Rennen";
				break;					
			default:
				$race = "Unknown";
				break;
		}
		return $race;
	}

	// Formatiert die Zahl mit zwei Nachkommastellen
	function format_fraction($number)
	{
		return floor(100 * $number) / 100;
	}
	
	// Formatiert die Zahl ohne Nachkommastellen
	function format_integer($number)
	{
		return round($number);
	}

	// Formatiert die Zahl prozentual mit zwei Nachkommastellen
	function format_percentage($number, $total)
	{
		return format_fraction(100 * ($number / $total)) . "%";
	}

	// Wandelt die Zeit in einen Zeit-String um.
	function format_time_string($time)
	{
		// Zeit für Ausgabe vorbereiten
		$min = floor($time / 60000);
		$sec = floor(($time - ($min * 60000)) / 1000);
		$mil = substr($time - ($min * 60000) - ($sec * 1000), 0, 3);
		return $min . ":" . ($sec < 10 ? "0" : "") . $sec . "." . ($mil < 100 ? "0" : "") . ($mil < 10 ? "0" : "") . $mil;
	}

	// Bildet die Zeit-Differenz aus den zwei Zeiten
	function format_time_difference_string($first_time, $second_time)
	{
		$diff = $first_time - $second_time;
		$result = "";
		if ($diff < 0)
		{
			$diff = -$diff;
			$result = "-";
		}
		return $result . format_time_string($diff);
	}
?>