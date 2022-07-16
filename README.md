# rum
reporting getter
A console-based client program for class to connect to a local MySQL database, execute one SQL query and export result to file.


- Get by git clone:
Windows: git clone -b wind https://github.com/remjw/rum.git rumw

mac: git clone -b apple https://github.com/remjw/rum.git ruma

- Or download and unzip the archive:
Unzip `rumw.zip`or `ruma.zip` to a folder and run from there in a terminal.

 

Files:
    1. rum/ 
    The folder contains The executable rum.

    2. config.ini: 
    Configuration parameters for database service and others. You need to update the credentials under the [mysql] group, usr and pwd or port, to match yours.

    3. sql/*.sql: 
    The sql folder contains five samples: q1.sql, q2.sql, q3.sql, q4.sql, q5.sql. You can add your own sql scripts to the folder.
        q5.sql: contains a syntax error
    Each script only contains one query. Currently rum is immature and only do one SQL SELECT statement in one run. 

    4. report/*: 
    (to-be-created) rum writes each report to a subfolder of this folder.

    5. log/log.txt: 
    (to-be-created) rum appends new logs to log.txt in the log folder.

Usage: 
    In the Terminal or CMD (Windows Commands), run the command: 

    rum.exe q=<queryfile> [r=<filename>] [f=<fileformat>]

    rum runs the SQL statement in the file `queryfile` and save the result to  `filename/filename.fileformat` in the report folder which is within the directory where you enter the rum command.

Arguments:

If no argument is specified, rum runs a sample:
    rum q=q1.sql r=q1 f=csv
to execute `q1.sql` from the `sql folder`, and write the result to the `q1 subfolder` in the `report folder`. 

    q=<queryfile>
        Required. The SQL query file. The queryfile must be in the sql folder. The queryfile must contain only one query. 
        
        In each queryfile, the first line must be a commnent line, and you must write the database name in the comment line. 
        -- dbname
        Refer to the samples in the sql folder.
        
        NOT-to-do: The command uses the SPACE as delimitor/separator. To make life easier, DO NOT include SPACE character in filename. 

    r=<filename>
        name of the subfolder to save the report. If not specified, the default name is the name of the queryfile without the extension.

    f=<fileformat>
        The format of the report file(s).
        If not specified, the default format is csv.
        Supported formats: csv, json, html, latex.
    

Example Commands: 

    rum.exe q=q1.sql r=q1 

    rum.exe q=q1.sql r=flights_table f=json

    rum.exe q=q1.sql f=html 

    rum.exe q=q1.sql f=latex

    rum.exe q=q2.sql r=flight_dfw_ord f=json

    rum.exe q=q2.sql r=flight_dfw_ord f=html


Relevant Libraries, Chunking & Streaming Options in Pandas read_sql API and SQLAlchemy:

Pandas is an Python library for data manipulation and analysis so it is easy-to-use. With Pandas read_sql API, the program fetches data from a relational database into a Pandas dataframe. The benefits of using pandas include the subsequent data manipulation and engineering can easily be done within Pandas with its versatile APIs. 

However, for large amounts of data, using Pandas APIs in their plain mode can slow down the execution, and even the memory may not fit for loading the entire data in one batch. So we should know a few advanced parameters regarding fetching large amounts of data from a database.

1. The chunksize option of read_sql function: The number of rows to fetch from the database at a time. The default value is 100.

For instance, the default Pandas.read_sql returns the query result entirely in a single Pandas dataframe, Pandas.read_sql function has a chunking option which returns a generator instead. A generator is an iterator which implements lazy evaluation (call-by-need). The iterator won't fetch anything until the data is being requestd/consumed by the user.

We can iterate over the generator and process each chunk in a loop. The iterator generates the next chunk per request, and the chunksize option determines the number of rows in each chunk. In each iteration, we write one chunk to a file. And at a later time, we may merge them together to form the final result.

2. use_pandas_metadata option: The default value is False. When set to True, the Pandas metadata will be used to speed up the query.

This option is used to control whether the Pandas metadata is used to control the chunking. If this option is set to True, the Pandas metadata is used to control the chunking. If this option is set to False, the chunking is controlled by the chunksize option.

3. The server-side cursors (streaming cursors) in SQLAlchemy: In the SQLAlchemy.create_engine().connect().execution_options() function, set stream_results to True. The default value is False. When set to True, the SQLAlchemy will use server-side cursors to fetch the data. This option is used to control whether the server-side cursors are used. 


Relevant concepts:
Ref.: https://docs.sqlalchemy.org/en/14/core/connections.html#using-server-side-cursors-a-k-a-stream-results
A client side cursor here means that the database driver fully fetches all rows from a result set into memory before returning from a statement execution. Drivers such as those of PostgreSQL and MySQL/MariaDB generally use client side cursors by default. A server side cursor, by contrast, indicates that result rows remain pending within the database server’s state as result rows are consumed by the client. The drivers for Oracle generally use a “server side” model, for example, and the SQLite dialect, while not using a real “client/server” architecture, still uses an unbuffered result fetching approach that will leave result rows outside of process memory before they are consumed.

Buffered vs. unbuffered result sets: 

Server side cursors also imply a wider set of features with relational databases, such as the ability to scroll a cursor forwards and backwards. SQLAlchemy does not include any explicit support for these behaviors; within SQLAlchemy itself, the general term “server side cursors” should be considered to mean "unbuffered results", and "client side cursors" means "result rows are buffered into memory before the first row is returned". 


Be aware that an individual row-fetch operations with fully unbuffered server side cursors are typically more expensive than fetching batches of rows at once. So if you are using a server side cursor, you should consider using a buffered cursor.

4. Streaming with a fixed sized buffer: The default value is False. When set to True, the SQLAlchemy will use a fixed sized buffer to fetch the data. 
    
