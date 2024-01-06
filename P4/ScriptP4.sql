-- SIBD 2023/2024, Etapa 4, Grupo 29
-- Miguel Simoes 60451 TP1?
-- Nuno Graxinha 59855 TP15
-- Sofia Santos 59804 TP15
-- Os membros Nuno e Sofia contribuiram de igual forma 
-- para o projeto (proporcionalmente metade para cada)
DROP TABLE viagem;
DROP TABLE taxi;
DROP TABLE motorista;

----------------------------------------------------------------------------

CREATE TABLE motorista (
  nif        NUMBER  (9),
  nome       VARCHAR (80) CONSTRAINT nn_motorista_nome       NOT NULL,
  genero     CHAR    (1)  CONSTRAINT nn_motorista_genero     NOT NULL,
  nascimento NUMBER  (4)  CONSTRAINT nn_motorista_nascimento NOT NULL,
  localidade VARCHAR (80) CONSTRAINT nn_motorista_localidade NOT NULL,
--
  CONSTRAINT pk_motorista
    PRIMARY KEY (nif),
--
  CONSTRAINT ck_motorista_nif  -- RIA 10.
    CHECK (nif BETWEEN 100000000 AND 999999999),
--
  CONSTRAINT ck_motorista_genero  -- RIA 11.
    CHECK (UPPER(genero) IN ('F', 'M')),  -- F(eminino), M(asculino).
--
  CONSTRAINT ck_motorista_nascimento  -- N�o suporta RIA 6, mas
    CHECK (nascimento > 1900)         -- impede erros b�sicos.
);

-- ----------------------------------------------------------------------------

CREATE TABLE taxi (
  matricula   CHAR    (6),
  ano         NUMBER  (4)   CONSTRAINT nn_taxi_ano         NOT NULL,
  marca       VARCHAR (20)  CONSTRAINT nn_taxi_marca       NOT NULL,
  conforto    CHAR    (1)   CONSTRAINT nn_taxi_conforto    NOT NULL,
  eurosminuto NUMBER  (4,2) CONSTRAINT nn_taxi_eurosminuto NOT NULL,
--
  CONSTRAINT pk_taxi
    PRIMARY KEY (matricula),
--
  CONSTRAINT ck_taxi_matricula
    CHECK (LENGTH(matricula) = 6),
--
  CONSTRAINT ck_taxi_ano  -- N�o suporta RIA 7, mas
    CHECK (ano > 1900),   -- impede erros b�sicos.
--
  CONSTRAINT ck_taxi_conforto  -- RIA 16.
    CHECK (UPPER(conforto) IN ('B', 'L')),  -- B(�sico), L(uxuoso).
--
  CONSTRAINT ck_taxi_eurosminuto  -- RIA 17 (adaptada a esta tabela).
    CHECK (eurosminuto > 0.0)
);

-- ----------------------------------------------------------------------------

CREATE TABLE viagem (
  motorista,
  inicio      DATE,
  fim         DATE       CONSTRAINT nn_viagem_fim         NOT NULL,
  taxi                   CONSTRAINT nn_viagem_taxi        NOT NULL,
  passageiros NUMBER (1) CONSTRAINT nn_viagem_passageiros NOT NULL,
--
  CONSTRAINT pk_viagem
    PRIMARY KEY (motorista, inicio),  -- Simplifica��o.
--
  CONSTRAINT fk_viagem_motorista
    FOREIGN KEY (motorista)
    REFERENCES motorista (nif),
--
  CONSTRAINT fk_viagem_taxi
    FOREIGN KEY (taxi)
    REFERENCES taxi (matricula),
--
  CONSTRAINT ck_viagem_periodo  -- RIA 5 (adaptada a esta tabela).
    CHECK (inicio < fim),
--
  CONSTRAINT ck_viagem_passageiros  -- RIA 19.
    CHECK (passageiros BETWEEN 1 AND 8)
);
-- --------------------------------------------------------------------------
-- insert motorista.
EXECUTE PKG_TAXI.regista_motorista  ('917258191','Sofia Afonso' ,'F', '2001', ' Porto');

EXECUTE PKG_TAXI.regista_motorista  ('917258192','Afonso' ,'M', '2000', ' Lisboa');

EXECUTE PKG_TAXI.regista_motorista ('917258193','Beatriz Afonso' ,'F', '2002', ' Porto');

EXECUTE PKG_TAXI.regista_motorista ('917258194','Catarina Afonso' ,'F', '2002', ' Porto');

EXECUTE PKG_TAXI.regista_motorista ('917258195','joana Afonso' ,'F', '2002', ' Porto');

EXECUTE PKG_TAXI.regista_motorista ('917258111','Joao Pedro' ,'M', '2002', ' Porto');

EXECUTE PKG_TAXI.regista_motorista ('917258112','Duarte Afonso' ,'M', '2002', ' Porto');

EXECUTE PKG_TAXI.regista_motorista (123456789, 'Mario', 'M', 1990, 'Porto');
     
EXECUTE PKG_TAXI.regista_motorista (111222333, 'Joana', 'F', 1980, 'Lisboa');
     
EXECUTE PKG_TAXI.regista_motorista (999888777, 'Maria', 'F', 1989, 'Lisboa');
     
EXECUTE PKG_TAXI.regista_motorista (999666333, 'Ana', 'F', 1988, 'Lisboa');
-- ----------------------------------------------------------------------------
-- insert taxi.

EXECUTE PKG_TAXI.regista_taxi ('ABC123', 2020, 'Toyota', 'B', TO_NUMBER('8.5', '999.99'));

EXECUTE PKG_TAXI.regista_taxi ('AA11AA', 1999, 'Renault', 'L', TO_NUMBER('2.0', '999.99'));

EXECUTE PKG_TAXI.regista_taxi('BA11AA', 1999, 'Renault', 'L', TO_NUMBER('3.0', '999.99'));

EXECUTE PKG_TAXI.regista_taxi ('BB22BB', 2005, 'Audi', 'L', TO_NUMBER('3.0', '999.99'));

EXECUTE PKG_TAXI.regista_taxi ('BA22BB', 2005, 'Audi', 'L', TO_NUMBER('5.0', '999.99'));
    
EXECUTE PKG_TAXI.regista_taxi ('CB22CB', 2005, 'Lancia', 'L', TO_NUMBER('3.0', '999.99'));

EXECUTE PKG_TAXI.regista_taxi ('AA01BB', 2010, 'Mercedes', 'B', TO_NUMBER('5.0', '999.99'));
          
EXECUTE PKG_TAXI.regista_taxi ('AB12CD', 2015, 'Lexus', 'B', TO_NUMBER('10.2', '999.99'));
     
EXECUTE PKG_TAXI.regista_taxi ('BB22EE', 2014, 'Lexus', 'L', TO_NUMBER('12.2', '999.99'));
     
EXECUTE PKG_TAXI.regista_taxi ('CC33CC', 2000, 'Lexus', 'B', TO_NUMBER('11.0', '999.99'));

-- atualiza eurosminuto.
EXECUTE PKG_TAXI.regista_taxi ('CC33CC', 2000, 'Lexus', 'B', TO_NUMBER('6.5', '999.99'));

-- ----------------------------------------------------------------------------
-- insert viagem.
EXECUTE pkg_taxi.regista_viagem ('917258191',TO_DATE('2023/05/03 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2023/05/03 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'BB22BB','7');

EXECUTE pkg_taxi.regista_viagem ('917258192',TO_DATE('2023/12/31 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2023/12/31 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'BB22BB','3');

EXECUTE pkg_taxi.regista_viagem ('917258193',TO_DATE('2023/11/24 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2023/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'AA11AA','3');

EXECUTE pkg_taxi.regista_viagem ('917258194',TO_DATE('2023/11/24 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2023/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'BB22BB','3');

EXECUTE pkg_taxi.regista_viagem ('917258195',TO_DATE('2023/11/24 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2023/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'BA11AA','3');

EXECUTE pkg_taxi.regista_viagem ('917258112',TO_DATE('2022/12/22 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2022/12/22 10:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'BA22BB','3');

EXECUTE pkg_taxi.regista_viagem ('917258194',TO_DATE('2022/11/23 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2022/11/24 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'BB22BB','3');

EXECUTE pkg_taxi.regista_viagem ('917258111',TO_DATE('2022/9/12 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2022/9/13 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'CB22CB','2');

EXECUTE pkg_taxi.regista_viagem ('917258112',TO_DATE('2022/9/15 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2022/9/16 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'CB22CB','2');
     
EXECUTE pkg_taxi.regista_viagem ('917258112',TO_DATE('2022/9/18 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2022/9/19 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'CB22CB','2');
     
EXECUTE pkg_taxi.regista_viagem ('917258111',TO_DATE('2022/9/24 9:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2022/9/25 18:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'CB22CB','3');

--Teste insert
SELECT * FROM viagem;

--Teste add sobreposiçao
EXECUTE pkg_taxi.regista_viagem ('917258111',TO_DATE('2022/9/24 10:00:00', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2022/9/25 19:00:00', 'yyyy/mm/dd hh24:mi:ss'), 'CB22CB','5');

SELECT * FROM viagem;

--Teste remove viagem
EXECUTE pkg_taxi.remove_viagem ('917258111',TO_DATE('2022/9/24 10:00:00', 'yyyy/mm/dd hh24:mi:ss'));

SELECT * FROM viagem;


--Teste remove motoristas  
EXECUTE PKG_TAXI.remove_motorista (111222333);

EXECUTE PKG_TAXI.remove_motorista (999888777);

EXECUTE PKG_TAXI.remove_motorista (999666333);

--Teste remove taxi
EXECUTE PKG_TAXI.remove_taxi ('ABC123');
