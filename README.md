 <p align="center">
<a href= "https://img.shields.io/github/repo-size/felipebacelo/BR-Capitals?style=for-the-badge"><img src="https://img.shields.io/github/repo-size/felipebacelo/BR-Capitals?style=for-the-badge"/></a>
<a href= "https://img.shields.io/github/languages/count/felipebacelo/BR-Capitals?style=for-the-badge"><img src="https://img.shields.io/github/languages/count/felipebacelo/BR-Capitals?style=for-the-badge"/></a>
<a href= "https://img.shields.io/github/forks/felipebacelo/BR-Capitals?style=for-the-badge"><img src="https://img.shields.io/github/forks/felipebacelo/BR-Capitals?style=for-the-badge"/></a>
<a href= "https://img.shields.io/bitbucket/pr-raw/felipebacelo/BR-Capitals?style=for-the-badge"><img src="https://img.shields.io/bitbucket/pr-raw/felipebacelo/BR-Capitals?style=for-the-badge"/></a>
<a href= "https://img.shields.io/bitbucket/issues/felipebacelo/BR-Capitals?style=for-the-badge"><img src="https://img.shields.io/bitbucket/issues/felipebacelo/BR-Capitals?style=for-the-badge"/></a>
</p>

# Análise de Distância das Capitais

## Objetivo ##

<p>Contribuir com um trabalho analítico extraindo informações e storytelling baseados em dados para insights bem como, uma forma de desenvolver e consolidar meus conhecimentos no campo da análise de dados desenvolvendo uma análise descritiva com o uso da linguagem de programação R através da IDE RStudio.</p>

## Origem dos Dados ##

<p>O primeiro passo para essa aventura foi encontrar as coordenadas geográficas das capitais de todo o mundo.</p>
<p>Os dados necessários para realizar está análise estão disponíveis em: https://lab.lmnixon.org/4th/worldcapitals.html.</p>

## Instalação das Ferramentas ##
  
  - [R - 4.1.0](https://www.r-project.org/)
  - [RSudio - 1.4.1725](https://rstudio.com/)

## Desenvolvimento ##

### Leitura da Base ###

<p>Os dados com as coordenadas geográficas das capitais estão contidos em um documento HTML.</p>
<p>Iniciamos obtendo o HTML através do pacote {httr}, em seguida, usamos o pacote {xml2} para localizar a tabela, e o pacote {rvest} para transformar essa tabela. Os pacotes {tibble} e {janitor} foram usados para deixar a tabela formatada.

### Manipulação dos Dados ###

<p>Aqui começamos a transformação dos dados. Verificamos que as coordenadas de latitude e longitude estavam em formato de texto e, ao invés de mostrar valores positivos e negativos, mostrava os valores N (norte), S (sul), E (leste), W (oeste). Além disso, a latitude e longitude de Jerusalém (Israel) estava incorreta.</p>
<p>Com os dados arrumados em mãos, calculamos as distâncias através da distância geodésica, usando latitude e longitude como base e o maravilhoso pacote {sf}. São duas funções principais: a sf::st_point() que cria um objeto especial do tipo ponto, e a sf::st_distance() que calcula a distância entre dois pontos. Utilizamos map2() e map() do pacote {purrr} para fazer e aplicar essas operações em todos os países. No final, temos a base ordenada pelas distâncias. As distâncias são calculadas em metros, que transformamos para quilômetros.</p>

### Visualizações ###

<p>As capitais mais próximas estão nesta tabela. Sem muitas surpresas aqui: como Brasília fica na região central do país, a capital mais próxima é a do Paraguai, seguida por outros países da América do Sul.</p>
<p align="center">
<img src="https://github.com/felipebacelo/BR-Capitals/blob/main/IMAGES/PLOT-1.png"/></p>
<p>As coisas ficam mais interessantes quando visualizamos as capitais mais distantes e temos nosso resultado: Koror (Palau) é a capital mais distante da capital, Brasília, seguida por Manila (Filipinas) e Saipan (Ilhas Mariana do Norte).</p>
<p align="center">
<img src="https://github.com/felipebacelo/BR-Capitals/blob/main/IMAGES/PLOT-2.png"/></p>
<p>Agora, utilizamos o pacote {leaflet} para visualizar o mapa 2D.</p>
<p align="center">
<img src="https://github.com/felipebacelo/BR-Capitals/blob/main/IMAGES/PLOT-3.png"/></p>
<p>Olhando o mapa acima (e considerando que a terra é esférica), parece mesmo que esses países estão bem longe, mesmo tentando acessar pelo leste ou pelo oeste</p>
<p>E, já que a terra é esférica, que tal criar um mapa 3D? Fizemos isso usando o pacote {plotly}.</p>
<p align="center">
<img src="https://github.com/felipebacelo/BR-Capitals/blob/main/IMAGES/PLOT-4.png"/></p>

## Referências ##
  
* [Curso-R](https://curso-r.com/)
* [R para Data Science](https://r4ds.had.co.nz/)

## Licenças ##

_MIT License_
_Copyright   ©   2021 Felipe Bacelo Rodrigues_
