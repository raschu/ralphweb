<?php
	// Anzahl Kilometer pro Kanton in einem Kuchendiagramm
	function kilometers_per_canton()
	{
		global $pdo;
		$url = "";

		// Totale Anzahl Kilometer
		$total = 0;
		$sql = "SELECT SUM(kilometers) anzahl
				FROM scranking
				WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5'";
		foreach ($pdo->query($sql) as $data)
		{
			$total = $data["anzahl"];
		}

		// Anzahl Kilometer pro Kanton
		$labels = "";
		$points = "";
		$sql = "SELECT kanton, SUM(kilometers) anzahl
				FROM scranking
				WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5'
				GROUP BY kanton
				ORDER BY anzahl DESC";
		foreach ($pdo->query($sql) as $data)
		{
			if ($labels != "")
			{
				$labels .= "|";
			}
			$labels .= $data["kanton"] . " (" . format_fraction($data["anzahl"]) . ", " . format_percentage($data["anzahl"], $total) . ")";

			if ($points != "")
			{
				$points .= ",";
			}
			// Google scheint mit grossen Zahlen nichts anfangen zu können -> skalieren
			$points .= format_fraction($data["anzahl"] / 1000);
		}
		$url = "http://chart.apis.google.com/chart?chs=530x300&cht=p&chtt=Anzahl Kilometer pro Kanton&chco=FF3333,FFFF33,33FF33&chl=" . $labels . "&chd=t:" . $points;
		return $url;
	}
?>
