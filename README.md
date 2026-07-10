## <center> Análise de dados - Spotify </center>
Módulo de dados - Laboratória

🎤 O projeto tem como objetivo realizar uma análise do conjunto de dados de streaming da plataforma Spotify, assim como de concorrentes, para entender possíveis sinais que indiquem o sucesso de uma música dentro da plataforma. Além disso, o projeto visa criar um panorama das faixas levantadas e a relevância das suas características para o seu sucesso, buscando descobrir se existe algum sinal precoce que indique o sucesso de uma música no Spotify. 

### 📻 Ferramentas e tecnologias
- BigQuery (Plataforma em nuvem da Google) e Structured Query Language (SQL): Utilizados para as etapas de limpeza, tratamento e padronização dos dados.
- Excel: Utilizado para avaliação e validação de informações.
- Data Studio (antigo Looker Studio): Plataforma utilizada para a visualização das informações e elaboração do dashboard.

### 💿 Contexto dos dados
O conjunto de dados é formado por duas tabelas fornecidas pela Laboratória, com informações coletadas até o ano de 2023. 
- Tabela 1: track_in_spotify
  - Caminho: spotifybarbara26.spotify1set.track_in_spotify_ativa_BR.
  - Volume: Cerca de 850 registros.
  - Descrição: Aborda informações acerca das músicas mais ouvidas, como país de lançamento, artistas e números de streams.
  - Colunas originais:
    - track_id (INTEGER): Identificador único da música (número inteiro de 7 dígitos, não repetido). 
    - track_name (STRING): Nome da música. 
    - artists_name (STRING): Nome do(s) artista(s). 
    - artist_count (INTEGER): Número de artistas que participam da música. 
    - main_music_genre (STRING): Principal gênero musical da música. 
    - main_country (STRING): Principal país da música. 
    - released_year (INTEGER): Ano de lançamento. 
    - released_month (INTEGER): Mês de lançamento. 
    - released_day (INTEGER): Dia do mês em que foi lançada. 
    - in_spotify_playlists (STRING): Número de playlists do Spotify em que a música está incluída. 
    - in_spotify_charts (INTEGER): Presença e posição da música nos rankings do Spotify. 
    - streams (INTEGER): Número total de reproduções no Spotify.
      
- Tabela 2: track_in_competition
   - Caminho: spotifybarbara26.spotify1set.track_in_competition _ativa_BR
   - Volume: Cerca de 950 registros.
   - Descrição: Detalha a presença das faixas em outras plataformas de streaming (Apple Music e Deezer) e no Shazam, em relação ao número de playlists e posicionamento em charts.
   - Colunas originais:
     - track_id (STRING): Identificador único da música (número inteiro de 7 dígitos, não repetido). 
     - in_apple_playlists (INTEGER): Número de playlists do Apple Music em que a música está incluída. 
     - in_apple_charts (INTEGER): Presença e posição da música nos rankings do Apple Music. 
     - in_deezer_playlists (INTEGER): Número de playlists do Deezer em que a música está incluída. 
     - in_deezer_charts (INTEGER): Presença e posição da música nos rankings do Deezer. 
     - in_shazam_charts (INTEGER): Presença e posição da música nos rankings do Shazam.

### 🧹 Processamento e Limpeza dos dados
- Validação e Alteração de Tipos de Dados: A coluna track_id na tabela track_in_spotify estava como INTEGER, mas por se tratar de um identificador único com o qual não se realizam operações matemáticas, o tipo apropriado definido foi STRING. A coluna in_spotify_playlists estava configurada originalmente como STRING e necessitava ser alterada para INTEGER.
- Tratamento de Valores Nulos:
  - Na tabela track_in_spotify, as colunas main_music_genre e main_country possuíam valores nulos para o registro da música 'Style' da artista 'Taylor Swift'. Por serem dados públicos, foram inseridos os valores 'Pop' e 'United States'.
  - Na tabela track_in_competition, foram identificados 50 valores nulos na coluna in_shazam_charts. Como a regra de negócio engloba essa plataforma, os valores nulos foram substituídos por 0.
    
- Tratamento de Valores Duplicados:
  - Na tabela track_in_spotify, foram identificadas duplicatas com comportamentos variados:
    - Duplicados perfeitos (BackOutsideBoyz, Broke Boys, Privileged Rappers, The Astronaut): Uma das cópias foi removida. 
    - Músicas SNAP, SPIT IN MY FACE e Take My Breath: Foram mantidos apenas os registros com a maior quantidade de streams. 
    - Música About Damn Time (Lizzo): Mantida a versão com a data de lançamento mais recente (15/07/2022), que coincide com o álbum da artista.
  - Na tabela track_in_competition, a verificação com base no track_id indicou que não há registros duplicados.
    
- Tratamento de Valores Atípicos (Outliers):
    - Categóricos: Na coluna main_country da tabela track_in_spotify, identificou-se abreviações inconsistentes (USA, MX, PR) coexistindo com nomes completos (United States, Mexico, Puerto Rico). Elas foram padronizadas para seus respectivos nomes por extenso. 
    - Numéricos: Foi identificado um valor de streams igual a -1 para a música 'Love Grows (Where My Rosemary Goes)' de Edison Lighthouse. Esse registro também continha um texto inadequado na coluna in_spotify_playlists. O registro completo foi excluído para evitar distorções nas análises.

- Junção de Tabelas (JOIN): Após a limpeza individual, realizou-se um LEFT JOIN entre as tabelas tratadas utilizando a chave track_id, gerando a tabela consolidada final join_trakingspotify.

### 📈 Resultados e Conclusões
- Músicas em mais playlists e volume de streams: Foi identificada uma correlação forte (coeficiente de 0.78) entre streams e a presença em playlists do Spotify, indicando um impacto direto no volume de reproduções.
- Relação com o Shazam: A presença no ranking do Shazam possui correlação moderada com os rankings do Spotify (0.5761). No entanto, a correlação entre a presença em playlists do Spotify e os charts do Shazam é de apenas 0.0519, indicando que o Shazam não se traduz em um aumento efetivo de streams na plataforma do Spotify. 
- Outras correlações: Existe uma correlação forte (0.7125) entre a inclusão de músicas em playlists do Spotify e playlists do Apple Music.

### 🎛 Limitações e próximos passos
- Amostragem e Temporalidade: O conjunto atual reflete um recorte estático. É necessária uma amostragem mais abrangente e temporal para identificar tendências consolidadas e previsibilidade de sucesso. 
- Novas Fontes de Dados: Recomenda-se incorporar métricas de plataformas de redes sociais de vídeos curtos (como o TikTok), que atuam diretamente na viralização de faixas musicais. 
- Geografia das Informações: A coluna main_country mapeia a origem do artista e não o local de consumo. Para entender o sucesso geográfico, seriam necessários dados baseados no local onde o stream foi realizado. 
- Escalabilidade: As decisões sobre duplicatas foram executadas de forma manual e pontual por registro. Essa abordagem não é escalável para volumes massivos de dados, tornando crucial identificar a causa raiz das falhas na origem para evitar a entrada de dados inconsistentes. 


    
