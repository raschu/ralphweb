<?php
	@require("connect.php");
	@require("functions.php");

	if (isset($_SERVER["argv"]))
	{
		$args = $_SERVER["argv"];
		if (count($args) >= 1)
		{
			switch ($args{1})
			{
				case "player_per_canton":
					@require("player_per_canton.php");
					print @player_per_canton();
					break;
				case "crashes_per_canton":
					@require("crashes_per_canton.php");
					print @crashes_per_canton();
					break;
				case "kilometers_per_canton":
					@require("kilometers_per_canton.php");
					print @kilometers_per_canton();
					break;
				case "average_time_per_race":
					if (count($args) >= 2)
					{
						@require("average_time_per_race.php");
						print @average_time_per_race($args{2});
					}
					break;
				case "average_time_per_race_and_sex":
					if (count($args) >= 2)
					{
						@require("average_time_per_race_and_sex.php");
						print @average_time_per_race_and_sex($args{2});
					}
					break;
				case "male_versus_female_count":
					@require("male_versus_female_count.php");
					print @male_versus_female_count();
					break;
				case "time_distribution_per_race":
					if (count($args) >= 3)
					{
						@require("time_distribution_per_race.php");
						print @time_distribution_per_race($args{2}, $args{3});
					}
					break;
				case "time_difference_per_race_and_player":
					if (count($args) >= 3)
					{
						@require("time_difference_per_race_and_player.php");
						print @time_difference_per_race_and_player($args{2}, $args{3});
					}
					break;
			}
		}
	}

	@require("disconnect.php");
?>
