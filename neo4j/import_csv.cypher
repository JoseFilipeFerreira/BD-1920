// Criar clientes
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/cliente.csv" AS row
CREATE (:Cliente {id_cliente: toInteger(row.id_cliente), nome: row.nome, data_nascimento: row.data_nascimento, data_subscricao: row.data_subscricao, email: row.email, telemovel: row.telemovel, distrito: row.distrito});

// Criar livros
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/livro.csv" AS row
CREATE (:Livro {id_artigo: toInteger(row.id_artigo), titulo: row.titulo, preco: toFloat(row.preco), ano: toInteger(row.ano),classificacao: toInteger(row.classificacao), autor: row.autor, genero: row.genero, editora: row.editora, n_paginas: toInteger(row.n_paginas)});

// Criar jogos
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/jogo.csv" AS row
CREATE (:Jogo {id_artigo: toInteger(row.id_artigo), titulo: row.titulo, preco: toFloat(row.preco), ano: toInteger(row.ano),classificacao: toInteger(row.classificacao), plataforma: row.plataforma, idade_min: row.idade_min, publisher: row.publisher, n_jogadores_max: row.n_jogadores_max, genero: row.genero});

// Criar musicas
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/musica.csv" AS row
CREATE (:Musica {id_artigo: toInteger(row.id_artigo), titulo: row.titulo, preco: toFloat(row.preco), ano: toInteger(row.ano),classificacao: toInteger(row.classificacao), genero_musical: row.genero_musical, artista: row.artista, formato: row.formato});

// Criar compras
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/compra.csv" AS row
CREATE (:Compra {id_compra: toInteger(row.id_compra), montante: toFloat(row.montante), loja: row.loja, data_hora: row.data_hora, id_cliente: toInteger(row.id_cliente)});

// Criar stock
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/stock.csv" AS row
CREATE (:Stock {id_artigo: toInteger(row.id_artigo), loja: row.loja, qtd_disponivel: toInteger(row.qtd_disponivel), distrito: row.distrito});

// -----------------------------------------

CREATE INDEX ON :Cliente(id_cliente);
CREATE INDEX ON :Livro(id_artigo);
CREATE INDEX ON :Jogo(id_artigo);
CREATE INDEX ON :Musica(id_artigo);
//CREATE INDEX ON :Filme(id_artigo);
CREATE INDEX ON :Stock(id_artigo);


CREATE CONSTRAINT ON (c:Cliente) ASSERT c.id_cliente IS UNIQUE;
CREATE CONSTRAINT ON (l:Livro) ASSERT l.id_artigo IS UNIQUE;
CREATE CONSTRAINT ON (j:Jogo) ASSERT j.id_artigo IS UNIQUE;
CREATE CONSTRAINT ON (m:Musica) ASSERT m.id_artigo IS UNIQUE;
//CREATE CONSTRAINT ON (f:Filme) ASSERT f.id_artigo IS UNIQUE;
CREATE CONSTRAINT ON (c:Compra) ASSERT c.id_compra IS UNIQUE;

// -----------------------------------------

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/compra.csv" AS row
MATCH (compra:Compra {id_compra: row.id_compra}),
      (cliente:Cliente {id_cliente: row.id_cliente})
CREATE (cliente)-[:FAZ]->(compra);

MATCH (a:Artist),(b:Album)
WHERE a.Name = "Strapping Young Lad" AND b.Name = "Heavy as a Really Heavy Thing"
CREATE (a)-[r:RELEASED]->(b)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/compra.csv" AS row
MATCH (compra:Compra {id_compra: row.id_compra})
MATCH (livro:Livro {id_artigo: row.id_artigo})
MERGE (compra)-[:DE]->(livro);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/compra.csv" AS row
MATCH (compra:Compra {id_compra: row.id_compra})
MATCH (jogo:Jogo {id_artigo: row.id_artigo})
MERGE (compra)-[:DE]->(jogo);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/compra.csv" AS row
MATCH (compra:Compra {id_compra: row.id_compra})
MATCH (musica:Musica {id_artigo: row.id_artigo})
MERGE (compra)-[:DE]->(musica);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/teste/stock.csv" AS row
MATCH (artigo:Artigo {id_artigo: row.id_artigo})
MATCH (stock:Stock {id_artigo: row.id_artigo, loja: row.loja})
MERGE (artigo)-[:TEM]->(stock);