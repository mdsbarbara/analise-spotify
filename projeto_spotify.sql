-- Códigos SQL utilizados no projeto Spotify

-- Pesquisa de valores nulos na tabela track_in_spotify.
-- Descrição: Realiza a contagem geral de registros para identificar quais colunas possuem campos nulos na tabela original do Spotify.
SELECT COUNT(*)
FROM spotifybarbara26.spotify1set.track_in_spotify_ativa_BR
WHERE
  track_id IS NULL
  OR track_name IS NULL
  OR artists_name IS NULL
  OR artist_count IS NULL
  OR main_music_genre IS NULL
  OR main_country IS NULL
  OR released_year IS NULL
  OR released_month IS NULL
  OR released_day IS NULL
  OR in_spotify_playlists IS NULL
  OR streams IS NULL;

-- Consulta 2: Pesquisa de valores nulos na tabela track_in_competition.
-- Descrição: Executa a contagem para mapear a presença de campos nulos entre as colunas da tabela de competidores.
SELECT Count(*)
FROM spotifybarbara26.spotify1set.track_in_competition _ativa_BR
WHERE
in_apple_playlists IS NULL
OR in_apple_charts IS NULL
OR in_deezer_playlists IS NULL
OR in_deezer_charts IS NULL
OR in_shazam_charts IS NULL;

-- Consulta 3: Criação da tabela spotifytracks_tratada (Tratamento Inicial).
-- Descrição: Cria a primeira tabela tratada convertendo track_id para STRING, corrigindo os valores nulos da música 'Style' com CASE WHEN e convertendo a coluna in_spotify_playlists para INT64 de forma segura com SAFE_CAST.
CREATE TABLE spotifybarbara26.spotify1set.spotifytracks_tratada AS
SELECT
CAST(track_id AS STRING) AS track_id,
track_name,
artists_name,
artist_count,
CASE
WHEN track_name = 'Style' AND artists_name = 'Taylor Swift'
THEN 'Pop'
ELSE main_music_genre
END AS main_music_genre,
CASE
WHEN track_name = 'Style' AND artists_name = 'Taylor Swift'
THEN 'United States'
ELSE main_country
END AS main_country,
released_year,
released_month,
released_day,
SAFE_CAST (in_spotify_playlists AS INT64) AS in_spotify_playlist,
in_spotify_charts,
streams
FROM spotifybarbara26.spotify1set.track_in_spotify_ativa_BR;

-- Consulta 4: Tratamento de nulos na tabela de competição.
-- Descrição: Gera a tabela spotifycompetition_tratada aplicando a função COALESCE para substituir os valores nulos encontrados na coluna in_shazam_charts por 0.
CREATE TABLE spotifybarbara26.spotify1set.spotifycompetition_tratada AS
SELECT
track_id,
in_apple_playlists,
in_apple_charts,
in_deezer_playlists,
in_deezer_charts,
COALESCE (in_shazam_charts, 0) AS in_shazam_charts
FROM spotifybarbara26.spotify1set.track_in_competition _ativa_BR;

-- Consulta 5: Identificação de duplicatas por nome de música e artista.
-- Descrição: Agrupa os registros por nome e artista da faixa utilizando o HAVING COUNT() > 1 para listar quais combinações aparecem de forma duplicada no dataset do Spotify.
SELECT track_name, artists_name, COUNT() AS Quantidade
FROM spotifybarbara26.spotify1set.track_in_spotify_ativa_BR
GROUP BY track_name, artists_name
HAVING COUNT(*) > 1;

-- Consulta 6: Remoção de duplicatas e geração da tabela versão 1.
-- Descrição: Utiliza SELECT DISTINCT para filtrar duplicatas exatas e a cláusula WHERE track_id NOT IN para eliminar manualmente os IDs duplicados divergentes que foram desconsiderados na análise.
CREATE OR REPLACE TABLE spotify1set.spotifytracks_tratadav1 AS
SELECT DISTINCT *
FROM spotifybarbara26.spotify1set.spotifytracks_tratada
WHERE track_id NOT IN (
'7173596',
'3814670',
'8173823',
'1119309'
);

-- Consulta 7: Identificação de registros duplicados na tabela de competidores.
-- Descrição: Agrupa a tabela tratada de competição por track_id com filtro HAVING para validar se restou algum identificador repetido.
SELECT
track_id,
COUNT() AS Quantidade FROM spotifybarbara26.spotify1set.spotifycompetition_tratada GROUP BY track_id HAVING COUNT() > 1;

-- Consulta 8: Mapeamento de valores únicos de países.
-- Descrição: Isola os valores da coluna main_country para identificar grafias atípicas ou falta de padronização nos registros de texto.
SELECT DISTINCT main_country
FROM spotifybarbara26.spotify1set.track_in_spotify_ativa_BR;

-- Análise de volumetria de países com agrupamento.
-- Descrição: Utiliza uma estrutura condicional para agrupar e visualizar temporariamente a quantidade de registros por país após a simulação da padronização dos termos USA, MX e PR.
SELECT
CASE
WHEN main_country IN ('United States', 'USA') THEN 'United States'
WHEN main_country IN ('Mexico', 'MX') THEN 'Mexico'
WHEN main_country IN ('Puerto Rico', 'PR') THEN 'Puerto Rico'
ELSE main_country
END AS pais_padronizado,
COUNt (*) AS quantidade
FROM spotifybarbara26.spotify1set.track_in_spotify_ativa_BR
GROUP BY pais_padronizado;

-- Consulta 10: Padronização categórica e geração da tabela versão 2.
-- Descrição: Cria a tabela spotifytracks_tratadav2 aplicando a padronização definitiva das siglas USA, PR e MX para seus respectivos nomes extensos através de condicionais CASE WHEN.
CREATE TABLE spotifybarbara26.spotify1set.spotifytracks_tratadav2 AS
SELECT
track_id,
track_name,
artists_name,
artist_count,
main_music_genre,
CASE
WHEN main_country = 'USA'
THEN 'United States'
WHEN main_country = 'PR'
THEN 'Puerto Rico'
WHEN main_country = 'MX'
THEN 'Mexico'
ELSE main_country
END AS main_country,
released_year,
released_month,
released_day,
in_spotify_playlist,
in_spotify_charts,
streams
FROM spotifybarbara26.spotify1set.spotifytracks_tratadav1;

-- Consulta 11: Análise de métricas descritivas da coluna streams.
-- Descrição: Executa as funções agregadas MAX, MIN e AVG sobre a coluna de streams para identificar a presença de valores inconsistentes ou discrepantes.
SELECT
MAX(streams) AS max_streams,
MIN(streams) AS min_streams,
AVG(streams) AS avg_streams
FROM spotifybarbara26.spotify1set.track_in_spotify_ativa_BR;

-- Consulta 12: Localização de registros com streams negativos.
-- Descrição: Filtra a tabela original para extrair todas as colunas das linhas que apresentam contagem de reproduções menor do que zero.
SELECT *
FROM spotifybarbara26.spotify1set.track_in_spotify_ativa_BR
WHERE streams < 0;

-- Consulta 13: Exclusão de registro atípico por ID na tabela versão 2.
-- Descrição: Reconstrói a tabela spotifytracks_tratadav2 excluindo definitivamente o registro da música com o track_id '4061483', cujo volume de streams constava como inválido
CREATE OR REPLACE TABLE spotifybarbara26.spotify1set.spotifytracks_tratadav2 AS
SELECT
track_id,
track_name,
artists_name,
artist_count,
main_music_genre,
main_country,
released_year,
released_month,
released_day,
in_spotify_playlist,
in_spotify_charts,
streams
FROM spotifybarbara26.spotify1set.spotifytracks_tratadav2
WHERE track_id NOT IN ('4061483');

-- Consulta 14: Consolidação final através de LEFT JOIN.
-- Descrição: Combina de forma definitiva as duas tabelas tratadas (spotifytracks_tratadav2 e spotifycompetition_tratada) baseando-se na igualdade do campo track_id para criar a tabela unificada join_trakingspotify.
CREATE TABLE spotify1set.join_trakingspotify AS
SELECT
trackspotify.track_id,
trackspotify.track_name,
trackspotify.artists_name,
trackspotify.artist_count,
trackspotify.main_music_genre,
trackspotify.main_country,
trackspotify.released_year,
trackspotify.released_month,
trackspotify.in_spotify_playlists,
trackspotify.in_spotify_charts,
trackspotify.streams,
competition.in_apple_playlists,
competition.in_apple_charts,
competition.in_deezer_playlists,
competition.in_deezer_charts,
competition.in_shazam_charts
FROM spotifybarbara26.spotify1set.spotifytracks_tratadav2 AS trackspotify
LEFT JOIN
spotifybarbara26.spotify1set.spotifycompetition_tratada AS competition
ON trackspotify.track_id = competition.track_id;
