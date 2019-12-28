/* Criar função idade (dada pelos docentes da UC) */
Use FNAC;
SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER //
CREATE FUNCTION `idade` (dta date) RETURNS INT
BEGIN
RETURN TIMESTAMPDIFF(YEAR, dta, CURDATE());
END //
DELIMITER ;

-- adiciona o montante de cada compra
-- (utilizar se fizerem os inserts antes de ativar o trigger)
drop procedure if exists montante;
DELIMITER //
create procedure montante()
begin

declare id   int;
declare soma decimal(6,2);
declare done bool;
declare qtd int;

declare curs1 cursor for
	select c.id_compra, (sum(a.preco*c.quantidade))
	from Compra_de_X_Artigos c
	join Artigo a on a.id_artigo = c.id_artigo
	group by c.id_compra;
declare continue handler for not found set done = true;

open curs1;
loop_name: loop
fetch curs1 into id, soma;

if done then
	leave loop_name;
end if;

update Compra
set montante = soma
where id_compra = id;

end loop;
close curs1;

end //
DELIMITER ;

call montante();

-- atualiza sempre que é adicionada uma compra e atualiza o stock
drop trigger if exists atualiza_montante;
DELIMITER //
create trigger atualiza_montante
after insert on Compra_de_X_Artigos
for each row
begin

declare new_preco decimal(6,2);
set new_preco = (select preco from Artigo where id_artigo = new.id_artigo);

update Compra
set montante = montante + (new_preco * new.quantidade)
where id_compra = new.id_compra;

update Stock
set qtd_disponivel = qtd_disponivel - new.quantidade
where id_artigo = new.id_artigo;

end;
//
DELIMITER ;

-- pesquisa completa dos livros
drop view if exists livros_titulo_asc;
create view livros_titulo_asc as
select a.id_artigo as Id, a.titulo as Título, l.autor as Autor,
a.preco as Preço, a.ano as Publicado, a.classificacao as Classificação,
l.genero as Género, l.editora as Editora, l.n_paginas as `Nº Páginas`
from Livro l join Artigo a on a.id_artigo = l.id_artigo
order by a.titulo ASC;

select * from livros_titulo_asc;

-- pesquisa completa dos filmes
drop view if exists filmes_titulo_asc;
create view filmes_titulo_asc as
select a.id_artigo as Id, a.titulo as Título, f.realizador as Realizador,
a.preco as Preço, a.ano as Ano, a.classificacao as Classificação,
f.genero as Género, f.duracao as Duração
from Filme f join Artigo a on a.id_artigo = f.id_artigo
order by a.titulo ASC;

select * from filmes_titulo_asc;

-- pesquisa completa dos jogos
drop view if exists jogos_titulo_asc;
create view jogos_titulo_asc as
select a.id_artigo as Id, a.titulo as Título, j.plataforma as Plataforma, a.preco as Preço,
a.ano as Ano, a.classificacao as Classificação, j.genero as Género,
j.publisher as Editor, j.idade_min as `Idade Mínima`, j.n_jogadores_max as `Nº Max Jogadores`
from Jogo j join Artigo a on a.id_artigo = j.id_artigo
order by a.titulo ASC;

select * from jogos_titulo_asc;

-- pesquisa completa das musicas --
drop view if exists musicas_titulo_asc;
create view musicas_titulo_asc as
select a.id_artigo as Id, a.titulo as Título, m.artista as Artista,
m.formato as Formato, a.preco as Preço, a.ano as Publicado,
a.classificacao as Classificação, m.genero_musical as Género
from Musica m join Artigo a on a.id_artigo = m.id_artigo
order by a.titulo ASC;

select * from musicas_titulo_asc;

-- pesquisar livros de um autor
drop procedure if exists livros_autor;
DELIMITER //
create procedure livros_autor(in autor varchar(45))
begin
select a.titulo as Título, a.preco as Preço,
a.ano as Publicado, a.classificacao as Classificação,
l.genero as Género, l.editora as Editora, l.n_paginas as Nº_Páginas
from Livro l join Artigo a on a.id_artigo = l.id_artigo
where l.autor = autor
order by a.titulo ASC;
end //
DELIMITER ;

call livros_autor('Jane Austen');

-- verifica que jogos o utilizador X  é permitido a comprar
drop procedure if exists jogos_permitidos;
DELIMITER //
create procedure jogos_permitidos(in id int)
begin
	select * from jogos_titulo_asc j, Cliente c
	where c.id_cliente = id
    and idade(c.data_nascimento) >= j.`Idade Mínima`;
end //
DELIMITER ;

call jogos_permitidos(1);

-- quanto cada autor já vendeu no total (quantidade e montante total) ordenado por lucro total e qtd decrescente
drop view if exists top_vendas_autor;
create view top_vendas_autor as
select l.autor as Autor, sum(a.preco*c.quantidade) as `Montante Total`, sum(c.quantidade) as `Quantidade Total`
from Compra_de_X_Artigos c
join Artigo a on a.id_artigo = c.id_artigo
join Livro l on c.id_artigo = l.id_artigo
group by l.autor
order by `Montante Total` DESC, `Quantidade Total` DESC;

select * from top_vendas_autor;

-- tipo especifico, ordenado por preço ascendente, classificacao descendente, com limites inferior e superior de preço
drop procedure if exists pesquisa_por_tipo;
DELIMITER //
create procedure pesquisa_por_tipo(in tipo_artigo varchar(45), in inf int, in sup int)
begin
select titulo as Título, preco as Preço,
ano as Publicado, classificacao as Classificação
from Artigo
where tipo = tipo_artigo and preco between inf and sup
order by preco ASC, classificacao DESC;
end //
DELIMITER ;

call pesquisa_por_tipo('Livro',10,20);

-- quantidade disponível em cada loja de um artigo
drop procedure if exists verifica_stock;
DELIMITER //
create procedure verifica_stock(in id int)
begin
	select * from Stock where id_artigo = id;
end //
DELIMITER ;

call verifica_stock(1);

-- quanto foi vendido em cada loja no ano x
drop procedure if exists vendas_loja;
DELIMITER //
create procedure vendas_loja(in ano int)
begin
	select c.loja as Loja, sum(x.quantidade) as Quantidade, sum(c.montante) as `Total Faturado`
	from Compra c join Compra_de_X_Artigos x on c.id_compra = x.id_compra
	where year(c.data_hora) = ano
	group by c.loja;
end //
DELIMITER ;

call vendas_loja(2019);

-- quanto foi vendido (qtd e preco) em cada mês no ano x
drop procedure if exists vendas_mes;
DELIMITER //
create procedure vendas_mes(in ano int)
begin
	select month(c.data_hora) as Mês, sum(x.quantidade) as Quantidade, sum(c.montante) as `Total Faturado`
	from Compra c join Compra_de_X_Artigos x on c.id_compra = x.id_compra
	where year(c.data_hora) = ano
	group by month(c.data_hora);
end //
DELIMITER ;

call vendas_mes(2019);

-- verifica a existência de stock de um artigo Y perto de um cliente X (no mesmo distrito)
drop procedure if exists stock_near_me;
DELIMITER //
create procedure stock_near_me(in id_c int, in id_a int)
begin
	select s.loja as Loja, s.qtd_disponivel as `Stock`
    from Cliente c, Stock s
    where s.id_artigo = id_a
    and c.id_cliente = id_c
    and s.distrito = c.distrito
    and s.qtd_disponivel > 0;
end //
DELIMITER ;

call stock_near_me(11,1);

-- por cada ano:
-- que loja lucrou mais?
-- quanto lucro?
-- qual foi a média entre lojas desse ano?
drop procedure if exists analise_anual;
DELIMITER //
create procedure analise_anual()
begin

	declare ano int;
	declare done bool;
    
    declare curs1 cursor for
		select year(data_hora) from Compra group by year(data_hora);
	declare continue handler for not found set done = true;
    
    drop table if exists `Análise Anual`;
    create table `Análise Anual` (`Ano` int, `Loja` varchar(45), `Maior Lucro` decimal(7,2), `Média` decimal(6,2));
    
    open curs1;
    loop_name: loop
    fetch curs1 into ano;
    
    if done then
		leave loop_name;
	end if;
    
    insert into `Análise Anual` (Ano, Loja, `Maior Lucro`, `Média`)
		(select ano, get_loja.l, results.x, results.average
		from (select ano, max(total) as x, avg(total) as average
			  from (select loja, sum(montante) as total
					from Compra
					where year(data_hora) = ano
					group by loja) as linha
		) as results
		join (select loja as l, year(data_hora) as ano, sum(montante) as total
			  from Compra
			  group by year(data_hora), loja
			  order by year(data_hora)
		) as get_loja
		on results.x = get_loja.total);
    
    end loop;
    close curs1;
    
    select * from `Análise Anual`;
    drop table `Análise Anual`;

end //
DELIMITER ;

call analise_anual();