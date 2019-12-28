
// Criar clientes
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/cliente.csv" AS row
CREATE (:Cliente {id_cliente: row.id_cliente, nome: row.nome, data_nascimento: row.data_nascimento, data_subscricao: row.data_subscricao, email: row.email, telemovel: row.telemovel, distrito: row.distrito});

// Criar livros
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/livro.csv" AS row
CREATE (:Livro {id_artigo: row.id_artigo, titulo: row.titulo, preco: toFloat(row.preco), ano: row.ano,classificacao: row.classificacao, autor: row.autor, genero: row.genero, editora: row.editora, n_paginas: row.n_paginas});

// Criar jogos
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/jogo.csv" AS row
CREATE (:Jogo {id_artigo: row.id_artigo, titulo: row.titulo, preco: toFloat(row.preco), ano: row.ano,classificacao: row.classificacao, plataforma: row.plataforma, idade_min: row.idade_min, publisher: row.publisher, n_jogadores_max: row.n_jogadores_max, genero: row.genero});

// Criar musicas
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/musica.csv" AS row
CREATE (:Musica {id_artigo: row.id_artigo, titulo: row.titulo, preco: toFloat(row.preco), ano: row.ano,classificacao: row.classificacao, genero_musical: row.genero_musical, artista: row.artista, formato: row.formato});

// Criar filmes
// USING PERIODIC COMMIT
// LOAD CSV WITH HEADERS FROM "file:/filme.csv" AS row
// CREATE (:Filme {id_artigo: row.id_artigo, titulo: row.titulo, preco: toFloat(row.preco), ano: row.ano,classificacao: row.classificacao, });

// Criar compras ??
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/compra.csv" AS row
CREATE (:Compra {id_compra: row.id_compra, montante: toFloat(row.montante), loja: row.loja, data_hora: row.data_hora, id_cliente: row.id_cliente, id_artigo: row.id_artigo, quantidade: row.quantidade});

// ??
// USING PERIODIC COMMIT
// LOAD CSV WITH HEADERS FROM "file:/orders.csv" AS row
// MERGE (order:Order {orderID: row.OrderID}) ON CREATE SET order.shipName =  row.ShipName;

// -----------------------------------------

CREATE INDEX ON :Cliente(id_cliente);
CREATE INDEX ON :Livro(id_artigo);
CREATE INDEX ON :Jogo(id_artigo);
CREATE INDEX ON :Musica(id_artigo);
//CREATE INDEX ON :Filme(id_artigo);
CREATE INDEX ON :Stock(id_artigo);
CREATE INDEX ON :Compra(id_compra);

// -----------------------------------------

//CREATE CONSTRAINT ON (c:Compra) ASSERT c.id_compra IS UNIQUE;

// -----------------------------------------

//schema await

// -----------------------------------------

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/orders.csv" AS row
MATCH (order:Order {orderID: row.OrderID})
MATCH (product:Product {productID: row.ProductID})
MERGE (order)-[pu:PRODUCT]->(product)
ON CREATE SET pu.unitPrice = toFloat(row.UnitPrice), pu.quantity = toFloat(row.Quantity);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/compra.csv" AS row
MATCH (compra:Compra {id_compra: row.id_compra})
MATCH (livro:Livro {id_artigo: row.id_artigo})
MERGE (compra)-[de:DE]->(livro)
ON CREATE SET de.montante = toFloat(row.montante), de.quantidade = toFloat(row.quantidade);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/orders.csv" AS row
MATCH (order:Order {orderID: row.OrderID})
MATCH (employee:Employee {employeeID: row.EmployeeID})
MERGE (employee)-[:SOLD]->(order);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/orders.csv" AS row
MATCH (order:Order {orderID: row.OrderID})
MATCH (customer:Customer {customerID: row.CustomerID})
MERGE (customer)-[:PURCHASED]->(order);

// -----------------------------------------

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/products.csv" AS row
MATCH (product:Product {productID: row.ProductID})
MATCH (supplier:Supplier {supplierID: row.SupplierID})
MERGE (supplier)-[:SUPPLIES]->(product);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/products.csv" AS row
MATCH (product:Product {productID: row.ProductID})
MATCH (category:Category {categoryID: row.CategoryID})
MERGE (product)-[:PART_OF]->(category);

// -----------------------------------------

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:/employees.csv" AS row
MATCH (employee:Employee {employeeID: row.EmployeeID})
MATCH (manager:Employee {employeeID: row.ReportsTo})
MERGE (employee)-[:REPORTS_TO]->(manager);