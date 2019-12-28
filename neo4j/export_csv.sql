COPY (SELECT * FROM Cliente) TO '/tmp/cliente.csv' WITH CSV header;

-- COPY (SELECT * FROM Artigo
--       JOIN Filme ON Filme.id_artigo = Artigo.id_artigo) TO '/tmp/filme.csv' WITH CSV header;

COPY (SELECT Artigo.id_artigo,titulo,tipo,preco,ano,classificacao,autor,genero,editora,n_paginas FROM Artigo
      JOIN Livro ON Livro.id_artigo = Artigo.id_artigo) TO '/tmp/livro.csv' WITH CSV header;

COPY (SELECT Artigo.id_artigo,titulo,tipo,preco,ano,classificacao,plataforma,idade_min,publisher,n_jogadores_max,genero FROM Artigo
      JOIN Jogo ON Jogo.id_artigo = Artigo.id_artigo) TO '/tmp/jogo.csv' WITH CSV header;

COPY (SELECT Artigo.id_artigo,titulo,tipo,preco,ano,classificacao,genero_musical,artista,formato FROM Artigo
      JOIN Musica ON Musica.id_artigo = Artigo.id_artigo) TO '/tmp/musica.csv' WITH CSV header;

COPY (SELECT * FROM Stock) TO '/tmp/stock.csv' WITH CSV header;

COPY (SELECT Compra.id_compra,montante,loja,data_hora,id_cliente,id_artigo,quantidade FROM Compra
      JOIN Compra_de_X_Artigos ON Compra.id_compra = Compra_de_X_Artigos.id_compra) TO '/tmp/compra.csv' WITH CSV header;