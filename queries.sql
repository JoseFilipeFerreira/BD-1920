-- adiciona o montante de cada compra
-- (utilizar se fizerem os inserts antes de ativar o trigger)

drop procedure montante;
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

-- atualiza sempre que é adicionada uma compra
-- também atualiza o stock

drop trigger atualiza_montante;
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

-- é preciso verificar se existe stock suficiente antes de permitir a compra ??