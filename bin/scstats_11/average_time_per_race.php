<?php
	// Sämtliche Durchschnittszeiten für ein Rennen in einem Balkendiagramm
	// (Gröeden Quali, Rennen, Bormio Quali, Rennen, ...)
	function average_time_per_race($race_type)
	{
		global $pdo;
		$url = "";

		// Durchschnittszeit pro Kanton
		$kanton = "";
		$labels_left = "";
		$labels_right = "";
		$points = "";
		$min_time = "";
		$max_time = "";
		$sql = "SELECT kanton,
				ROUND(
					AVG(
						SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
						SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
						SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
					)
				) zeit,
				COUNT(" . $race_type . ") anzahl
				FROM scranking
				WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND " . $race_type . " <> 0 AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5'
				GROUP BY kanton
				ORDER BY zeit ASC";
		foreach ($pdo->query($sql) as $data)
		{
			$labels_left = $data["kanton"] . "|" . $labels_left;

			if ($labels_right == "")
			{
				$labels_right = format_time_string($data["zeit"]) . " (" . $data["anzahl"] . " Fahrer)";
			} else {
				$labels_right = format_time_string($data["zeit"]) . " (" . $data["anzahl"] . " Fahrer)|" . $labels_right;
			}

			if ($min_time == "")
			{
				$min_time = $data["zeit"] - 1000;
			}
			$max_time = $data["zeit"] + 1000;

			if ($points != "")
			{
				$points .= ",";
			}
			$points .= $data["zeit"];
		}
		$url = "http://chart.apis.google.com/chart?chs=400x740&cht=bhs&chtt=" . resolve_race_title($race_type) . " (Durchschnitt/Kanton)&chds=" . $min_time . "," . $max_time . "&chxt=y,r&chco=237fbe&chxl=0:|" . $labels_left . "1:|" . $labels_right . "&chd=t:" . $points;
		return $url;
	}
?>