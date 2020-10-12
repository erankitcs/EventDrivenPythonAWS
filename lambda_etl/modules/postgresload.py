import psycopg2
import os
import psycopg2.extras

db_host = os.environ['DB_HOST']
db_port = os.environ['DB_PORT']
db_name = os.environ['DB_NAME']
db_user = os.environ['DB_USER']
db_pass = os.environ['DB_PASS']

def create_conn():
    conn = None
    try:
        conn = psycopg2.connect("dbname={} user={} host={} password={}".format(db_name,db_user,db_host,db_pass))
    except:
        print("Cannot connect.")
    return conn

def create_table(conn, table):
    cursor = conn.cursor()
    create_table_query = "CREATE TABLE {} (DATE date PRIMARY KEY NOT NULL, CASES INT , DEATHS INT , RECOVERED INT )".format(table)
    try:
        cursor.execute(create_table_query)
        print("Table created successfully.",table)
    except (Exception, psycopg2.Error) as error :
        print("Failed to CREATE  table", error)

def insert_table(conn, table, data):
    cursor = conn.cursor()
    df_columns = list(data)
    columns = ",".join(df_columns)
    values = "VALUES({})".format(",".join(["%s" for _ in df_columns]))
    insert_stmt = "INSERT INTO {} ({}) {}".format(table,columns,values)
    print(insert_stmt)
    psycopg2.extras.execute_batch(cursor, insert_stmt, data.values)
    conn.commit()

def check_fullload(conn, table):
    cursor = conn.cursor()
    query = "SELECT count(*) FROM {}".format(table)
    try:
       cursor.execute(query)
       count = int(cursor.fetchone()[0])
       if count > 0 :
        return False
       else:
        return True
    except (Exception, psycopg2.Error) as error :
        print("Failed to read count of the table", error)
        return 1

def get_max_date(conn, table):
    cursor = conn.cursor()
    query = "SELECT max(date) FROM {}".format(table)
    try:
       cursor.execute(query)
       max_date = cursor.fetchone()[0]
       return max_date
    except (Exception, psycopg2.Error) as error :
        print("Failed to read count of the table", error)
        return 1


def fetch(conn, query):
    result = []
    print("Now executing: {}".format(query))
    cursor = conn.cursor()
    cursor.execute(query)

    raw = cursor.fetchall()
    for line in raw:
        result.append(line)

    return result