<?php
	try
	{
		$pdo = new PDO("sqlite:db/ralphsch_skicha.sqlite");
		$sql = "SELECT id, nick FROM sc11_ranking";
		foreach ($pdo->query($sql) as $row)
		{
			print $row["id"] . ": " . $row["nick"] . "<br />";
		}
		unset($pdo);
	}
	catch(Exception $e)
	{
		die($e->getMessage());
	}
?>