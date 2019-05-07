# Project-Plant
I need plant data from the following web site: http://www.worldfloraonline.org/
The data can be viewed at this link
http://www.worldfloraonline.org/classification. There is a hierarchy.
The top of the hierarchy is the order. The next down is the family.
The next down is the genus. The next down  is the specific epithet.
Below that are the varieties, subspecies, forms etc. This hierarchy is
called a taxon. In my database, orders are in one table. Families in
another. Genera (plural of genus) in another. Specific epithets,
varieties and subspecies are in a single table. The combination of
genus and specific epithet is called the binomial name of the plant.
Click on a binomial name to see information about that plant.

I have created files that will help you complete this project. They
are located here
http://--.---.--.---/plantfiles/ which is my computer.

The alangium files are images created from the worldfloraonline site
for the plant alangium chinense:
http://www.worldfloraonline.org/taxon/wfo-0000936752
The image files have been marked up to show what data I need and in
which tables that data should go. Review the table relationship file
to see how the tables are related. Each record has a unique key so
that it is easy to identify which species are linked to which genera,
which families, which orders and which synonyms. This will be a many
to one relationship, i.e. many species to one genus, many genera to
one family and many families to one order.

You need to install MySQL server and MySQL Workbench on your computer,
create a schema call worldfloraonline and import the tables into it.
There is a lot of data in these tables to show you how I have it
organized. The orders table is empty because my previous source of
data, The Plant List, did not have order data. Now delete all the data
in each table.

You will also find a Microsoft Access file with these same tables. It
is not necessary to use this file. It has the same data as the MySQL
server will have after to import the table. It is there in case you
want to see use it but you'll need Windows.

Write a Perl script that scrapes the worldfloraonline website to get
the data and add that data into the  respective tables. This is by far
the hardest part of this project. Include in the script the ability to
update current MySQL database should the data change.
