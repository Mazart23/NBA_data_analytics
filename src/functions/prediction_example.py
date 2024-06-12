import basketball_stan
import predict
import pandas as pd

df = pd.read_csv('src\\data\\games\\2019_2020_season.csv')

fitted_model = basketball_stan.fit_model(stan_file="stan\\model_bin.stan", data=df, iterations=10000, chains=4)

outcome_probability = predict.predict_game(model_fit = fitted_model, data = df, home_team = 'ORLANDO MAGIC', away_team = 'TORONTO RAPTORS', model = 'NB')
print(outcome_probability)

scoreline_probability = predict.predict_game(model_fit = fitted_model, data = df, home_team = 'ORLANDO MAGIC', away_team = 'TORONTO RAPTORS', model = 'NB', score_lines=True)
print(scoreline_probability)