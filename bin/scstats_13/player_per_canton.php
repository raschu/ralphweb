<?php
	// Anzahl Spieler pro Kanton in einem Kuchendiagramm
	function player_per_canton()
	{
		global $pdo;
		$url = "";

		// Totale Anzahl Spieler
		$total = 0;
		$sql = "SELECT COUNT(nick) anzahl
				FROM scranking
				WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5'";
		foreach ($pdo->query($sql) as $data)
		{
			$total = $data["anzahl"];
		}

		// Anzahl Spieler pro Kanton
		$labels = "";
		$points = "";
		$min = -1;
		$max = -1;
		$sql = "SELECT kanton, COUNT(kanton) anzahl
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
			$labels .= $data["kanton"] . " (" . $data["anzahl"] . ", " . format_percentage($data["anzahl"], $total) . ")";

			if ($points != "")
			{
				$points .= ",";
			}
			$points .= $data["anzahl"];
			if (($max == -1) || ($data["anzahl"] > $max))
			{
				$max = $data["anzahl"];
			}
			if (($min == -1) || ($data["anzahl"] < $min))
			{
				$min = $data["anzahl"];
			}
		}
		$url = "http://chart.apis.google.com/chart?chs=450x300&cht=p&chtt=Anzahl Fahrer pro Kanton&chco=FF3333,FFFF33,33FF33&chds=" . $min . "," . $max . "&chl=" . $labels . "&chd=t:" . $points;
		return $url;
	}
?>
