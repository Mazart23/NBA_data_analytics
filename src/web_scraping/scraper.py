from typing import List

from basketball_reference_web_scraper import client
from basketball_reference_web_scraper.data import OutputType


def scrap_games(years: List[int]) -> None:
    for year in years:
        client.season_schedule(
            season_end_year=year,
            output_type=OutputType.CSV,
            output_file_path=f"src/data/games/{year-1}_{year}_season.csv"
        )
