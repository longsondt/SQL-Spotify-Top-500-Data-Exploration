	-- SPOTIFY Top 200 Weekly (Global) charts in 2020 & 2021 -- 
						-- Bruce Doan --

	/* 
	Foreword: The data set includes 1,556 songs that have been on 
	the Top 200 Weekly (Global) charts of Spotify in 2020 & 2021. 
	However, this could also be a "Top (number)" songs of 2020 & 2021 on Spotify
	by querying using CTEs and Top-ing it with the desired ranking range. 
	
	This specific query will limit the data to 500 songs, which effectively 
	turns this data set into a "Top 500 songs of Spotify in 2020 & 2021"
	*/

	-- 1. Simple data exploration --  

/* Premilinary view of the data set */
SELECT [Artist]
FROM dbo.spotify_dataset$;


/* Get name of artists of the top 10 most streamed songs */
SELECT TOP 10 [Song Name], [Artist], [Streams]
FROM dbo.spotify_dataset$;


/* Total streams of top 10 songs / Total streams of top 500 */
WITH top_500 AS
(
SELECT TOP 500 * 
FROM dbo.spotify_dataset$
), 
top_10_total_streams AS
(
SELECT sum([Streams]) AS [Total streams of top 10]
FROM (SELECT TOP 10 [Streams] FROM top_500) AS t
)
SELECT (top10.[Total streams of top 10]/top500.[Total streams of top 500]) * 100 AS Top10SongsAsAPercentageOfTop500TotalStreams
FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rn FROM top_10_total_streams)  as top10

INNER JOIN 

(SELECT SUM([Streams]) AS [Total streams of top 500], ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rn FROM top_500) as top500

ON top10.rn = top500.rn;


/* Get the top 5 songs that has the most number of times charted and ranking */
WITH top_500 AS
(
SELECT TOP 500 * 
FROM dbo.spotify_dataset$
) 
SELECT TOP 5 [Index] as [Rank#], [Number of Times Charted], [Song Name], [Streams], [Artist]
FROM top_500
ORDER BY [Number of Times Charted] DESC;


/* How many of the 500 songs has/belong to a particular aritst? */
WITH top_500 AS
(
SELECT TOP 500 *
FROM dbo.spotify_dataset$ 
)
SELECT [Song Name], [Artist]
FROM top_500
WHERE [Artist] LIKE '%Olivia Rodrigo%';


/* Total streams of a particular artist */
WITH top_500 AS
(
SELECT TOP 500 *
FROM dbo.spotify_dataset$ 
)
SELECT [Artist], SUM([Streams]) AS [Total Streams]
FROM top_500
WHERE [Artist] LIKE '%Polo G%'
GROUP BY [Artist];


/* Which artist has the most songs in this top 500?  */
WITH top_500 AS
(
SELECT TOP 500 *
FROM dbo.spotify_dataset$ 
),
Artist_Count AS
(
SELECT *, COUNT([Artist]) OVER(PARTITION BY [Artist]) AS [Total]
FROM top_500
) 
SELECT [Song Name], [Streams], [Artist], [Total] AS [Total Songs] 
FROM Artist_Count
WHERE [Total] = (SELECT MAX([Total]) FROM Artist_Count);


/* Top 10 artists who have the most songs in this top 500 */
WITH top_500 AS
(
SELECT TOP 500 *
FROM dbo.spotify_dataset$ 
),
Artist_Count AS
(
SELECT [Artist], COUNT([Artist]) AS [Total number of songs], SUM([Streams]) AS [Total Streams]
FROM top_500
GROUP BY [Artist]
) 
SELECT TOP 10 * 
FROM Artist_Count
ORDER BY [Total number of songs] DESC


/* How many of the songs were NOT actually released in 2020-2021?*/
WITH top_500 AS
(
SELECT TOP 500 *
FROM dbo.spotify_dataset$ 
)
SELECT [Index] AS [Rank#], [Song Name], [Artist], SUBSTRING([Release Date], 1, 4) AS [Release Year], [Streams]
FROM top_500
WHERE SUBSTRING([Release Date], 1, 4) NOT IN ('2020', '2021')
/* Exclude songs which release date is unavailable */
AND [Release Date] != '';


/* How many of the songs were released before a particular year?*/
WITH top_500 AS
(
SELECT TOP 500 *
FROM dbo.spotify_dataset$ 
)
SELECT [Index] AS [Rank#], [Song Name], [Artist], SUBSTRING([Release Date], 1, 4) AS [Release Year], [Streams]
FROM top_500
WHERE CAST(SUBSTRING([Release Date], 1, 4) AS int) < 2000 -- Input year cutoff here
AND [Release Date] != '';


