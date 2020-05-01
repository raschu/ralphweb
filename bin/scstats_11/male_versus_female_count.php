<?php
	// Anzahl Männer/Frauen im Verhältnis pro Kanton
	function male_versus_female_count()
	{
		global $pdo;
		$url = "";

		// Totale Anzahl Männer pro Kanton
		$max_count = 0;
		$labels_left = "";
		$labels_right = "";
		$male_points = "";
		$female_points = "";
		$sql = "SELECT kanton, COUNT(nick) anzahl
				FROM scranking
				WHERE kanton <> 'DI' AND kanton <> 'GM' AND kanton <> 'AT' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5' AND sex = 'm'
				GROUP BY kanton
				ORDER BY kanton ASC";
		foreach ($pdo->query($sql) as $data)
		{
			// Totale Anzahl Frauen in diesem Kanton
			$female_sql = "SELECT COUNT(nick) anzahl
					FROM scranking
					WHERE kanton = '" . $data["kanton"] . "' AND nick <> 'tora3' AND nick <> 'tora4' AND nick <> 'tora5' AND sex = 'f'";
			if ($female_data = $pdo->query($female_sql)->fetch())
			{
				$total = $data["anzahl"] + $female_data["anzahl"];
				if ($total > $max_count)
				{
					$max_count = $total;
				}

				$labels_left = $data["kanton"] . "|" . $labels_left;
				if ($labels_right == "")
				{
					$labels_right = $data["anzahl"] . " (" . format_percentage($data["anzahl"], $total) . "), " . $female_data["anzahl"] . " (" . format_percentage($female_data["anzahl"], $total) . ")";
				} else {
					$labels_right = $data["anzahl"] . " (" . format_percentage($data["anzahl"], $total) . "), " . $female_data["anzahl"] . " (" . format_percentage($female_data["anzahl"], $total) . ")|" . $labels_right;
				}

				// Daten der Frauen anfügen
				if ($female_points != "")
				{
					$female_points .= ",";
				}
				$female_points .= $female_data["anzahl"];
			} else {
				if ($female_points != "")
				{
					$female_points .= ",";
				}
				$female_points .= "0";
			}

			// Daten der Männer anfügen
			if ($male_points != "")
			{
				$male_points .= ",";
			}
			$male_points .= $data["anzahl"];
		}
		$url = "http://chart.apis.google.com/chart?chs=400x750&cht=bhs&chtt=Verhaeltnis Maenner/Frauen pro Kanton&chco=237fbe,FF6666&chdl=Maenner|Frauen&chdlp=b&chds=0," . $max_count . "&chxt=y,r&chxl=0:|" . $labels_left . "1:|" . $labels_right . "&chd=t:" . $male_points . "|" . $female_points;
		return $url;
	}
?>
