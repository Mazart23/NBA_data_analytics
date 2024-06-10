import basketball_stan
import pandas as pd

df = pd.read_csv('src\\data\\games\\2019_2020_season.csv')
print(df)

fitted_model = basketball_stan.fit_model(stan_file="stan\\model_bin.stan", data=df, iterations=10000, chains=4)

basketball_stan.plot_parameters(model_fit = fitted_model, data = df, model = 'NB') # figure 1
basketball_stan.plot_parameters_2d(model_fit = fitted_model, data = df, model = 'NB') # figure 2

# # Might want to add colour to the labels in the 2d plot to correspond to team colours
# new_cols = c('red','firebrick4','cyan', 'brown','darkblue','blue2','darkblue','cyan','blue','firebrick',
#              'deepskyblue','firebrick1','black','red','red','gray0','blue4', 'gold1', 'darkblue' ,'brown4')

# plot_parameters_2d(model_fit = NB, data = PL1718, model = 'NB', point_est = 'mean', cols = new_cols, overall =  T) # figure 3
