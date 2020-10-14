import psycopg2
import os
import psycopg2.extras

db_host = os.environ['DB_HOST']
db_port = os.environ['DB_PORT']
db_name = os.environ['DB_NAME']
#db_user = os.environ['DB_USER']
#db_pass = os.environ['DB_PASS']

def create_conn(db_user, db_pass):
    conn = None
    try:
        conn = psycopg2.connect("dbname={} user={} host={} password={}".format(db_name,db_user,db_host,db_pass))
        conn.autocommit = True
    except (Exception, psycopg2.Error) as error :
        print("Cannot connect.")
        raise Exception("Cannot connect to database. Error: {}".format(error))
    return conn

def create_table(conn, table):
    cursor = conn.cursor()
    create_table_query = "CREATE TABLE {} (DATE date PRIMARY KEY NOT NULL, CASES INT , DEATHS INT , RECOVERED INT )".format(table)
    try:
        cursor.execute(create_table_query)
    except psycopg2.Error as e:
        print(e)
        if cursor is not None:
            conn.rollback()
    finally:
        if cursor is not None:
            cursor.close()   
            print("Table created successfully or its available........")

def insert_table(conn, table, data):
 try:
    cursor = conn.cursor()
    df_columns = list(data)
    columns = ",".join(df_columns)
    values = "VALUES({})".format(",".join(["%s" for _ in df_columns]))
    insert_stmt = "INSERT INTO {} ({}) {}".format(table,columns,values)
    #print(insert_stmt)
    psycopg2.extras.execute_batch(cursor, insert_stmt, data.values)
    conn.commit()
    cursor.close()
 except (Exception, psycopg2.Error) as error :
        conn.rollback()
        cursor.close()
        print("Insert into table failed.", error)
        raise Exception(" Data load into Postgress failed. Error: {}".format(error))

def check_fullload(conn, table):
    cursor = conn.cursor()
    query = "SELECT count(*) FROM {}".format(table)
    try:
       cursor.execute(query)
       count = cursor.fetchone()[0]
       cursor.close()
       print(count)
       count = int(count)
       if count > 0 :
        return False
       else:
        return True
    except (Exception, psycopg2.Error) as error :
        cursor.close()
        print("Failed to read count of the table", error)
        raise Exception("Failed to read count of the table. Error: {}".format(error))

def get_max_date(conn, table):
    cursor = conn.cursor()
    query = "SELECT max(date) FROM {}".format(table)
    try:
       cursor.execute(query)
       max_date = cursor.fetchone()[0]
       cursor.close()
       return max_date
    except (Exception, psycopg2.Error) as error :
        cursor.close()
        print("Failed to read count of the table", error)
        raise Exception("Failed to read count of the table. Error: {}".format(error))


def fetch(conn, query):
 try:
    result = []
    print("Now executing: {}".format(query))
    cursor = conn.cursor()
    cursor.execute(query)

    raw = cursor.fetchall()
    for line in raw:
        result.append(line)
    cursor.close()
    return result
 except (Exception, psycopg2.Error) as error :
        cursor.close()
        print("Failed to read data of the table", error)
        raise Exception("Failed to read data of the table. Error: {}".format(error))