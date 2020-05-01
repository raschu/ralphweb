<?php
	// Verteilung der Zeiten in einem Balkendiagramm
	function time_distribution_per_race($race_type, $seconds)
	{
		global $pdo;
		$range_count = 26;
		$label_count = 15;
		$label_skip = 3;
		$url = "";

		// Min./Max. Zeit der Schweiz
		$max_count = 0;
		$labels_bottom = "";
		$labels_left = "";
		$points = "";
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
		foreach ($pdo->query($sql) as $data)
		{
			$range_part = $seconds * 1000 / $range_count;
			for ($i = 0; $i < $range_count; $i++)
			{
				if ($points != "")
				{
					$points .= ",";
				}
				$range_sql = "SELECT
								COUNT(nick) anzahl
							FROM scranking
							WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5' AND " . $race_type . " <> 0 AND (
								SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
								SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
								SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
							) > " . round($data["minzeit"] - 1 + ($i * $range_part)) . " AND (
								SUBSTR(" . $race_type . ", 1, LENGTH(" . $race_type . ") - 5) * 60000 +
								SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 4, 2) * 1000 +
								SUBSTR(" . $race_type . ", LENGTH(" . $race_type . ") - 2, 3)
							) <= " . round($data["minzeit"] + (($i + 1) * $range_part));
				if ($range_data = $pdo->query($range_sql)->fetch())
				{
					$points .= $range_data["anzahl"];
					if ($range_data["anzahl"] > $max_count)
					{
						$max_count = $range_data["anzahl"];
					}
				} else {
					$points .= "0";
				}
			}
			$labels_bottom = format_time_string($data["minzeit"]) . "|";
			for ($i = 1; $i < $range_count - 1; $i++)
			{
				if (($i % $label_skip != 0) || ($i >= $range_count - $label_skip))
				{
					$labels_bottom .= "|";
				} else {
					$labels_bottom .= format_time_string($data["minzeit"] + ((($seconds * 1000) / $range_count) * $i)) . "|";
				}
			}
			$labels_bottom .= format_time_string($data["minzeit"] + ($seconds * 1000));

			for ($i = 0; $i < $label_count; $i++)
			{
				$labels_left .= "|" . format_integer($i * ($max_count / $label_count));
			}

			$url = "http://chart.apis.google.com/chart?chs=500x300&chbh=13&cht=bvs&chtt=" . resolve_race_title($race_type) . "|(Verteilung der Zeiten bis zu einem Rueckstand von " . $seconds . " Sekunden)&chds=0," . $max_count . "&chxt=x,y&chco=237fbe&chxtc=1,-710&chxl=0:|" . $labels_bottom . "|1:" . $labels_left . "&chd=t:" . $points;
		}
		return $url;
	}
?>