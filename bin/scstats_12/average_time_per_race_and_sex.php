<?php
	// Sämtliche Durchschnittszeiten pro Geschlecht für ein Rennen in einem Balkendiagramm
	// (Gröeden Quali, Rennen, Bormio Quali, Rennen, ...)
	function average_time_per_race_and_sex($race_type)
	{
		global $pdo;
		$url = "";

		// Durchschnittszeit für Männer
		$labels_left = "";
		$labels_right = "";
		$points = "";
		$min_time = "";
		$max_time = "";
		$time = "";
		$sql = "SELECT
				ROUND(
					AVG(
						SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
						SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
						SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
					)
				) zeit,
				COUNT(" . $race_type . ") anzahl
				FROM scranking
				WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND " . $race_type . " <> 0 AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5' AND sex='m'";
		foreach ($pdo->query($sql) as $data)
		{
			// Durchschnittszeit für Frauen
			$labels_left = "";
			$labels_right = "";
			$points = "";
			$min_time = "";
			$max_time = "";
			$sql = "SELECT
					ROUND(
						AVG(
							SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
							SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
							SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
						)
					) zeit,
					COUNT(" . $race_type . ") anzahl
					FROM scranking
					WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND " . $race_type . " <> 0 AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5' AND sex='f'";
			foreach ($pdo->query($sql) as $female_data)
			{
				if ($female_data["zeit"] <= $data["zeit"])
				{
					$labels_left .= "Maenner (" . $data["anzahl"] . " Fahrer)|Frauen (" . $female_data["anzahl"] . " Fahrerinnen)";
					$labels_right .= format_time_string($data["zeit"]) . " (" . format_time_difference_string($data["zeit"], $female_data["zeit"]) . ")|" . format_time_string($female_data["zeit"]);

					$min_time = $female_data["zeit"] - 1000;
					$max_time = $data["zeit"] + 1000;

					$points = $female_data["zeit"] . "," . $data["zeit"];
				} else {
					$labels_left .= "Frauen (" . $female_data["anzahl"] . " Fahrerinnen)|Maenner (" . $data["anzahl"] . " Fahrer)";
					$labels_right .= format_time_string($female_data["zeit"]) . " (" . format_time_difference_string($female_data["zeit"], $data["zeit"]) . ")|" . format_time_string($data["zeit"]);

					$min_time = $data["zeit"] - 1000;
					$max_time = $female_data["zeit"] + 1000;

					$points = $data["zeit"] . "," . $female_data["zeit"];
				}
			}
		}

		$url = "http://chart.apis.google.com/chart?chs=400x100&cht=bhs&chtt=" . resolve_race_title($race_type) . " (Durchschnitt/Geschlecht)&chds=" . $min_time . "," . $max_time . "&chxt=y,r&chco=237fbe&chxl=0:|" . $labels_left . "|1:|" . $labels_right . "&chd=t:" . $points;
		return $url;
	}
?>