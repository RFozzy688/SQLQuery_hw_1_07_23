--Написать хранимую процедуру, которая показывает количество взятых книг по 
--каждой из групп, и по каждой из кафедр (Departments)

CREATE PROCEDURE count_book AS
SELECT g.name, COUNT(*) [amount]
FROM S_Cards sc JOIN Student s ON sc.id_student = s.id
JOIN Groups g ON s.id_group = g.id
GROUP BY g.name

UNION ALL 

SELECT d.name, COUNT(*) [amount]
FROM S_Cards sc JOIN Student s ON sc.id_student = s.id
JOIN Groups g ON s.id_group = g.id
JOIN Department d ON g.id_department = d.id
GROUP BY d.name

EXEC count_book

------------------------------------------------------------------------------------------------

--Написать хранимую процедуру, показывающую список книг, отвечающих набору критериев. 
--Критерии: имя автора, фамилия автора, тематика, категория. Кроме того, список должен 
--быть отсортирован по номеру поля, указанному в 5-м параметре, в направлении, указанном в 6-м параметре (sp_executesql)

CREATE PROCEDURE list_book 
	@firstName nvarchar(50), @lastName nvarchar(50), @theme nvarchar(50), @category nvarchar(50), 
	@field nvarchar(50),
	@sort nvarchar(50) AS
	DECLARE @str nvarchar(1000) = 'SELECT Book.name
	FROM Book JOIN Author ON Book.id_author = Author.id
	JOIN Category ON Book.id_category = Category.id
	JOIN Theme ON Book.id_theme = Theme.id
	WHERE Author.first_name = @name AND
	Author.last_name = @surName AND
	Theme.name = @themeBook AND 
	Category.name = @categoryBook
	ORDER BY ' + @field + ' ' + @sort

EXECUTE sp_executesql @str,  N'@name nvarchar(50), @surName nvarchar(50), @themeBook nvarchar(50), @categoryBook nvarchar(50), @field nvarchar(50), @sort nvarchar(50)',
							@firstName, @lastName, @theme, @category, @field, @sort

EXECUTE list_book 'Алексей', 'Архангельский', 'Программирование', 'C++ Builder', '1', 'DESC'

------------------------------------------------------------------------------------------------

--Написать хранимую процедуру, которая показывает список библиотекарей, и количество выданных каждым из них книг
CREATE PROCEDURE LibrarianTotalCount AS
SELECT last_name, SUM(amount) AS total_count
FROM 
	(SELECT l.last_name, COUNT(t_c.id_librarian) AS amount
	FROM Librarian l JOIN T_Cards t_c
	ON l.id = t_c.id_librarian
	GROUP BY l.last_name

	UNION ALL

	SELECT l.last_name, COUNT(s_c.id_librarian)
	FROM Librarian l JOIN S_Cards s_c
	ON l.id = s_c.id_librarian
	GROUP BY l.last_name) AS temp_result
GROUP BY last_name
ORDER BY 2 DESC

EXEC LibrarianTotalCount

------------------------------------------------------------------------------------------------

--Создать хранимую процедуру, которая покажет имя и фамилию студента, набравшего наибольшее количество книг
CREATE PROCEDURE StudentMaxCountBook AS
SELECT TOP 1 Student.first_name, Student.last_name, COUNT(*)
FROM Student JOIN S_Cards ON Student.id = S_Cards.id_student
WHERE S_Cards.date_out IS NOT NULL
GROUP BY Student.first_name, Student.last_name
ORDER BY 3 DESC

EXEC StudentMaxCountBook

------------------------------------------------------------------------------------------------

--Создание хранимой процедуры, которая вернёт общее количество взятых из библиотеки книг и преподавателями, и студентами
CREATE PROCEDURE TotalBook AS
SELECT SUM(amount) AS total_count
FROM 
	(SELECT COUNT(*) AS amount
	FROM T_Cards
	WHERE T_Cards.date_out IS NOT NULL

	UNION ALL

	SELECT COUNT(*)
	FROM S_Cards
	WHERE S_Cards.date_out IS NOT NULL) AS temp_result

EXEC TotalBook
