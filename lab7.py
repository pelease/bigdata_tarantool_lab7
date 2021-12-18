import pandas as pd
import tarantool
connection = tarantool.connect("localhost", 3301, user='admin', password='pass')

userlog = connection.space('userlog')


data = userlog.select()

df = pd.DataFrame(data, columns=['Day', 'TickTime', 'Speed'])

print('Медиана = ', df.groupby(['Day'])['Speed'].median())
print('Минимальное значение времени', df.groupby(['Day'])['TickTime'].min())
print('Максимальное значение времени:', df.groupby(['Day'])['TickTime'].max())
