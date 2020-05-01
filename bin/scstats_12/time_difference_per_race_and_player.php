<?php
	// Abweichung zur Durchschnittszeit für einen einzelnen Fahrer
	// pro Rennen in einem Balkendiagramm
	function time_difference_per_race_and_player($race_type, $nick)
	{
		global $pdo;
		$url = "";

		// Zeit des Spielers
		$sql = "SELECT kanton,
				ROUND(
					SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
					SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
					SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
				) zeit
				FROM scranking
				WHERE nick = '" . addslashes($nick) . "'";
		if ($nickdata = $pdo->query($sql)->fetch())
		{
			// Min./Max. Zeit des Spieler-Kantons
			$sql = "SELECT
					MIN(
						SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
						SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
						SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
					) minzeit,
					MAX(
						SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
						SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
						SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
					) maxzeit
					FROM scranking
					WHERE kanton = '" . $nickdata["kanton"] . "' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5' AND " . $race_type . " <> 0";
			if ($minmaxdata = $pdo->query($sql)->fetch())
			{
				// Min./Max. Zeit des Spieler-Kantons
				$sql = "SELECT
						MIN(
							SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
							SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
							SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
						) minzeit,
						MAX(
							SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
							SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
							SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
						) maxzeit
						FROM scranking
						WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5' AND " . $race_type . " <> 0";
				if ($chminmaxdata = $pdo->query($sql)->fetch())
				{
					// Durchschnittszeit für den Kanton
					$kanton = "";
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
							WHERE kanton = '" . $nickdata["kanton"] . "' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5' AND " . $race_type . " <> 0
							GROUP BY kanton
							ORDER BY zeit ASC";
					foreach ($pdo->query($sql) as $data)
					{
						$min_time = $minmaxdata["minzeit"] - 10000;
						$max_time = $minmaxdata["maxzeit"] + 10000;

						if ($nickdata["zeit"] <= $data["zeit"])
						{
							$labels_left = "Letzter Schweiz |" . "Letzter " . $data["kanton"] . "|" . "Durchschnitt " . $data["kanton"] . "|" . $nick . "|" . "Schnellster " . $data["kanton"] . "|" . "Schnellster Schweiz|";

							$labels_right =
								format_time_string($chminmaxdata["maxzeit"]) . " (" . format_time_difference_string($chminmaxdata["maxzeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($minmaxdata["maxzeit"]) . " (" . format_time_difference_string($minmaxdata["maxzeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($data["zeit"]) . " (" . format_time_difference_string($data["zeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($nickdata["zeit"]) . " (" . format_time_difference_string($nickdata["zeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($minmaxdata["minzeit"]) . " (" . format_time_difference_string($minmaxdata["minzeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($chminmaxdata["minzeit"]);

							$points = $chminmaxdata["minzeit"] . "," . $minmaxdata["minzeit"] . "," . $nickdata["zeit"] . "," . $data["zeit"] . "," . $minmaxdata["maxzeit"] . "," . $chminmaxdata["maxzeit"];
						} else {
							$labels_left = "Letzter Schweiz |" . "Letzter " . $data["kanton"] . "|" . $nick . "|" . "Durchschnitt " . $data["kanton"] . "|" . "Schnellster " . $data["kanton"] . "|" . "Schnellster Schweiz|";

							$labels_right =
								format_time_string($chminmaxdata["maxzeit"]) . " (" . format_time_difference_string($chminmaxdata["maxzeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($minmaxdata["maxzeit"]) . " (" . format_time_difference_string($minmaxdata["maxzeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($nickdata["zeit"]) . " (" . format_time_difference_string($nickdata["zeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($data["zeit"]) . " (" . format_time_difference_string($data["zeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($minmaxdata["minzeit"]) . " (" . format_time_difference_string($minmaxdata["minzeit"], $chminmaxdata["minzeit"]) . ")|" .
								format_time_string($chminmaxdata["minzeit"]);

							$points = $chminmaxdata["minzeit"] . "," . $minmaxdata["minzeit"] . "," . $data["zeit"] . "," . $nickdata["zeit"] . "," . $minmaxdata["maxzeit"] . "," . $chminmaxdata["maxzeit"];
						}

						$url = "http://chart.apis.google.com/chart?chs=350x200&cht=bhs&chtt=" . resolve_race_title($race_type) . " (Vergleich mit Kanton)&chds=" . $min_time . "," . $max_time . "&chxt=y,r&chco=237fbe&chxl=0:|" . $labels_left . "1:|" . $labels_right . "&chd=t:" . $points;
					}
				}
			}
		}
		return $url;
	}
?>