---
layout: reveal
title: "Reveal Pro: SQL DB explorer"
permalink: /reveal/feature/sql
---
## SQL DB explorer

You can get a better view of SQL database you use in your project using `db:explore` action on your JDBC connection source description (e.g. DataSource instance, JDBC URL or, if you use [next.jdbc](https://github.com/seancorfield/next-jdbc) or [clojure.java.jdbc](https://github.com/clojure/java.jdbc), a db spec map).

Here is what you can do with DB explorer:

1. Visualize database schema.

   You can view your database in the same way you think about it — as a graph with relations.

   <video controls><source src="/assets/reveal/db-schema.mp4" type="video/mp4"></source></video>

2. Explore relational data across multiple tables without writing joins.

   You can load data from multiple tables using schema-aware relation and column picker. In the same picker interface, you can apply free-form filters to columns, quickly getting the data you need.

   <video controls><source src="/assets/reveal/db-explore-table.mp4" type="video/mp4"></source></video>

3. Work with query results in the REPL.

   Working with data loaded from the database usually requires post-processing. With this explorer, you don't need to perform an export/import step that is necessary with external SQL clients — query results are available in the REPL as simple data structures.

   <video controls><source src="/assets/reveal/db-table-to-repl.mp4" type="video/mp4"></source></video>
