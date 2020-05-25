import sqlite3
conn = sqlite3.connect('example.db')

# Source: https://docs.python.org/3/library/sqlite3.html

c = conn.cursor()

#Create Table
c.execute('''CREATE TABLE stocks (date text, trans text, symbol test, qty real, price real)''')

# insert a row of data
c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")

# Save (commit) the changes
conn.commit()

# Print data using an iterator
for row in c.execute('SELECT * FROM stocks ORDER BY price'):
    print(row)

# close connection
conn.close()
