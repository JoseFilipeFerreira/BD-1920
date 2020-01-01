USE FNAC_TESTE;

SELECT * FROM Cliente;

-- SELECT * FROM Artigo
-- JOIN Filme ON Filme.id_artigo = Artigo.id_artigo;

SELECT Artigo.id_artigo,titulo,tipo,preco,ano,classificacao,autor,genero,editora,n_paginas
FROM Artigo JOIN Livro ON Livro.id_artigo = Artigo.id_artigo;

SELECT Artigo.id_artigo,titulo,tipo,preco,ano,classificacao,plataforma,idade_min,publisher,n_jogadores_max,genero
FROM Artigo JOIN Jogo ON Jogo.id_artigo = Artigo.id_artigo;

SELECT Artigo.id_artigo,titulo,tipo,preco,ano,classificacao,genero_musical,artista,formato
FROM Artigo JOIN Musica ON Musica.id_artigo = Artigo.id_artigo;

SELECT * FROM Stock;

SELECT * FROM Compra;

SELECT * FROM Compra_de_X_Artigos;

SELECT distinct loja, distrito FROM Stock
where id_artigo = 1;