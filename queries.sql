Use FNAC;

-- 13. tipo especifico, ordenado por preço ascendente, classificacao descendente, com limites inferior e superior de preço
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

-- 21. pesquisar livros de um autor
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

-- 22. verifica que jogos o utilizador X  é permitido a comprar
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

-- 23. views.sql

-- 24. quanto foi vendido em cada loja no ano x
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

-- 25. quanto foi vendido (qtd e preco) em cada mês no ano x
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

-- 26. verifica a existência de stock de um artigo Y perto de um cliente X (no mesmo distrito)
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

-- 27. por cada ano:
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