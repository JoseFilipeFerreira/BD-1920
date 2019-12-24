/* Criar função idade (dada pelos docentes da UC) */
Use FNAC;
SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER //
CREATE FUNCTION `idade` (dta date) RETURNS INT
BEGIN
RETURN TIMESTAMPDIFF(YEAR, dta, CURDATE());
END //
DELIMITER ;

-- formato DATE: '2016-01-23'

-- Regex Tester:
-- https://www.regextester.com/

-- Livros:
-- https://www.stjulians.com/media/40197/GCSE-Reading-List.pdf
-- https://www.boltonschool.org › media › reading-list
-- https://github.com/akshaybhatia10/Book-Genre-Classification --> para arranjar o genre de um livro
-- https://book-genre-classification.herokuapp.com/ --> testar online o programa anterior

-- Filmes:
-- https://readthedocs.org/projects/imdbpy/downloads/pdf/latest/

-- Jogos:
-- https://en.wikipedia.org/wiki/2019_in_video_gaming#Game_releases
-- https://www.sciencemuseum.org.uk/sites/default/files/2019-03/Power-UP-games-list.pdf
