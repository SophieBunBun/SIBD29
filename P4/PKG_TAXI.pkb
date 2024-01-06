create or replace PACKAGE BODY PKG_TAXI AS
-- SIBD 2023/2024, Etapa 4, Grupo 29
-- Miguel Simoes 60451 TP1?
-- Nuno Graxinha 59855 TP15
-- Sofia Santos 59804 TP15

-- Regista um novo motorista
PROCEDURE regista_motorista (nif_in        IN motorista.nif%TYPE,
                             nome_in       IN motorista.nome%TYPE,
                             genero_in     IN motorista.genero%TYPE,
                             nascimento_in IN motorista.nascimento%TYPE,
                             localidade_in IN motorista.localidade%TYPE) IS
                    
    idade NUMBER;
    idade_invalida EXCEPTION;
                             
BEGIN
    -- Calcula a idade com base na data (ano) de nascimento fornecida
    SELECT EXTRACT(YEAR FROM CURRENT_TIMESTAMP) - nascimento_in
    INTO idade
    FROM DUAL;
    
    -- Verifica se a idade eh inferior a 18 anos e, se for, levanta uma excecao personalizada
    IF (idade < 18 ) THEN
        RAISE idade_invalida;
    END IF;

    -- Insere o novo motorista na tabela, caso seja maior de idade
    INSERT INTO motorista(nif, nome, genero, nascimento, localidade)
         VALUES (nif_in, nome_in, genero_in, nascimento_in, localidade_in);
         
EXCEPTION
    -- Trata excecoes especificas relacionadas a restricoes e gera mensagens de erro personalizadas
    WHEN idade_invalida THEN
        RAISE_APPLICATION_ERROR(-20004, 'Motorista deve ter idade igual ou superior a 18 anos');
        
    WHEN OTHERS THEN 
    
        IF (SQLERRM = 'nn_motorista_nome') THEN
            RAISE_APPLICATION_ERROR(-20012,'nome nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'nn_motorista_genero') THEN
            RAISE_APPLICATION_ERROR(-20012,'genero nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'nn_motorista_nascimento') THEN
            RAISE_APPLICATION_ERROR(-20012,'nascimento nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'nn_motorista_localidade') THEN
            RAISE_APPLICATION_ERROR(-20012,'localidade nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'pk_motorista') THEN
            RAISE_APPLICATION_ERROR(-20112,'nif nao pode ser null ou tem de ser diferente de nif existentes');
        END IF;
        
        IF (SQLERRM = 'ck_motorista_nif') THEN
            RAISE_APPLICATION_ERROR(-20212,'nif tem de ser entre 100000000 e 999999999');
        END IF;
        
        IF (SQLERRM = 'ck_motorista_genero') THEN
            RAISE_APPLICATION_ERROR(-20312,'genero tem de ser F ou M');
        END IF;
        
        IF (SQLERRM = 'ck_motorista_nascimento') THEN
            RAISE_APPLICATION_ERROR(-20412,'nascimento tem de ser superior a 1900');
        END IF;
              
        RAISE_APPLICATION_ERROR(-20005,SQLCODE ||' -ERROR- '||SQLERRM);
END regista_motorista;

-- Registra um novo taxi
PROCEDURE regista_taxi(matricula_in   IN taxi.matricula%TYPE,
                       ano_in         IN taxi.ano%TYPE,
                       marca_in       IN taxi.marca%TYPE,
                       conforto_in    IN taxi.conforto%TYPE,
                       eurosminuto_in IN taxi.eurosminuto%TYPE) IS
                                           
 BEGIN                       
    DECLARE
        v_taxi_count INTEGER;
    BEGIN
    
        -- Verifica se um taxi com a mesma matricula ja existe e, se existir, atualiza o preco por minuto
        SELECT COUNT(*)
        INTO v_taxi_count
        FROM taxi
        WHERE matricula = matricula_in;
        
        IF v_taxi_count > 0 THEN
            UPDATE taxi
            SET eurosminuto = eurosminuto_in
            WHERE matricula = matricula_in;
        ELSE    
            -- Insere um novo taxi na tabela
            INSERT INTO taxi(matricula, ano, marca, conforto, eurosminuto)
            VALUES (matricula_in, ano_in, marca_in, conforto_in, eurosminuto_in);
        END IF;
             
EXCEPTION
    -- Trata excecoes especificas relacionadas a restricoes e gera mensagens de erro personalizadas
    WHEN OTHERS THEN
    
        IF (SQLERRM = 'nn_taxi_ano') THEN
            RAISE_APPLICATION_ERROR(-20011,'ano nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'nn_taxi_marca') THEN
            RAISE_APPLICATION_ERROR(-20011,'marca nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'nn_taxi_conforto') THEN
            RAISE_APPLICATION_ERROR(-20011,'conforto nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'nn_taxi_eurosminuto') THEN
            RAISE_APPLICATION_ERROR(-20011,'eurosminuto nao pode ser null');
        END IF;
    
        IF (SQLERRM = 'pk_taxi') THEN
            RAISE_APPLICATION_ERROR(-20111,'matricula nao pode ser null ou tem de ser diferente de matriculas existentes');
        END IF;
    
        IF (SQLERRM = 'ck_taxi_matricula') THEN
            RAISE_APPLICATION_ERROR(-20211,'matricula tem de ter 6 caracteres');
        END IF;
        
        IF (SQLERRM = 'ck_taxi_ano') THEN
            RAISE_APPLICATION_ERROR(-20311,'ano superior a 1900');
        END IF;
        
        IF (SQLERRM = 'ck_taxi_conforto') THEN
            RAISE_APPLICATION_ERROR(-20411,'conforto tem de ser B ou L');
        END IF;
        
        IF (SQLERRM = 'ck_taxi_eurosminuto') THEN
            RAISE_APPLICATION_ERROR(-20511,'eurosminuto tem de ser maior que zero');
        END IF;
    
        RAISE_APPLICATION_ERROR(-20007, SQLCODE ||' -ERROR- '|| SQLERRM);
    END;            
END regista_taxi;              
                       
-- Registra uma nova viagem
PROCEDURE regista_viagem (motorista_in   IN motorista.nif%TYPE,
                          inicio_in      IN DATE,
                          fim_in         IN DATE,
                          taxi_in        IN taxi.matricula%TYPE,
                          passageiros_in IN viagem.passageiros%TYPE) IS
    
    CURSOR c_viagens IS
        SELECT inicio, fim, taxi, motorista
        FROM viagem;
        
    TYPE local_viagens IS TABLE OF c_viagens%ROWTYPE;
    viagens local_viagens;
    
    viagem_invalida EXCEPTION;

BEGIN
    -- Recupera todas as viagens existentes
    OPEN c_viagens;
    FETCH c_viagens BULK COLLECT INTO viagens;
    CLOSE c_viagens;

    -- Verifica se ha conflitos com outras viagens para o mesmo taxi ou motorista no mesmo periodo
    IF (viagens.LAST ~= 0) THEN
        FOR pos IN viagens.FIRST..viagens.LAST LOOP      
            IF (viagens(pos).taxi = taxi_in OR viagens(pos).motorista = motorista_in) THEN
                IF ((viagens(pos).inicio > inicio_in AND viagens(pos).inicio < fim_in) 
                    OR (viagens(pos).fim > inicio_in AND viagens(pos).fim < fim_in)) THEN
                    
                        RAISE viagem_invalida; 
                        
                END IF;            
            END IF;
        END LOOP;
    END IF;
    -- Insere a nova viagem na tabela
     INSERT INTO viagem(motorista, taxi, inicio, fim, passageiros)
           VALUES (motorista_in, taxi_in, inicio_in, fim_in, passageiros_in);
    
EXCEPTION
    -- Trata excecoes especificas relacionadas a restricoes e gera mensagens de erro personalizadas
    WHEN viagem_invalida THEN
        RAISE_APPLICATION_ERROR(-20002, 'Taxi ou motorista ja registados' ||
        ' com outra viagem cujo tempo em que decorre interseta a introduzida');
        
     WHEN OTHERS THEN
        IF (SQLERRM = 'nn_viagem_fim') THEN
            RAISE_APPLICATION_ERROR(-20103,'Fim da viagem nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'nn_viagem_taxi') THEN
            RAISE_APPLICATION_ERROR(-20103,'Taxi nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'nn_viagem_passageiros') THEN
            RAISE_APPLICATION_ERROR(-20103,'Numero de passageiros nao pode ser null');
        END IF;
        
        IF (SQLERRM = 'pk_viagem') THEN
            RAISE_APPLICATION_ERROR(-20104,'Motorista e inicio nao podem ser null ou tem de ser diferente de viagens existentes');
        END IF;
        
        IF (SQLERRM = 'fk_viagem_motorista') THEN
            RAISE_APPLICATION_ERROR(-20105,'Motorista deve existir');
        END IF;
        
        IF (SQLERRM = 'fk_viagem_taxi') THEN
            RAISE_APPLICATION_ERROR(-20106,'Taxi deve existir');
        END IF;
        
        IF (SQLERRM = 'ck_viagem_periodo') THEN
            RAISE_APPLICATION_ERROR(-20107,'Inicio tem de ser menor que fim');
        END IF;
        
        IF (SQLERRM = 'ck_viagem_passageiros') THEN
            RAISE_APPLICATION_ERROR(-20108,'A viagem so pode ter entre 1 a 8 passageiros');
        END IF;
        
        RAISE_APPLICATION_ERROR(-20001,SQLCODE ||' -ERROR- '||SQLERRM);

END regista_viagem;
     
-- Remove uma viagem    
PROCEDURE remove_viagem (motorista_in IN motorista.nif%TYPE,
                         data_in      IN DATE) IS
               
    sem_remocao EXCEPTION;
                     
BEGIN
    -- Remove a viagem com base no NIF do motorista e na data especificada   
    DELETE FROM viagem WHERE (motorista = motorista_in
                              AND inicio <= data_in
                              AND data_in <= fim);
                              
    -- Se nenhuma linha for removida, levanta uma excecao                             
    IF (SQL%ROWCOUNT = 0) THEN
        RAISE sem_remocao;
    END IF;
                              
EXCEPTION
    -- Trata excecoes especificas relacionadas a restricoes e gera mensagens de erro personalizadas
    WHEN sem_remocao THEN
        RAISE_APPLICATION_ERROR(-20101,'0 linhas removidas');

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003,SQLCODE ||' -ERROR- ' ||SQLERRM);
        
END remove_viagem;

-- Remove um taxi
PROCEDURE remove_taxi(matricula_in IN taxi.matricula%TYPE) IS

    sem_remocao EXCEPTION;

BEGIN
    -- Para cada viagem associada ao taxi, chama a procedure remove_viagem para as remover
    FOR viagens IN (SELECT motorista, inicio
                      FROM viagem V
                     WHERE V.taxi = matricula_in) LOOP
        remove_viagem (viagens.motorista, viagens.inicio);
    END LOOP;
    
    -- Remove o taxi da tabela
    DELETE FROM taxi
          WHERE matricula = matricula_in;
          
    -- Se nenhuma linha for removida, levanta uma excecao                             
     IF (SQL%ROWCOUNT = 0) THEN
        RAISE sem_remocao;
    END IF;
          
EXCEPTION
    -- Trata excecoes especificas relacionadas a restricoes e gera mensagens de erro personalizadas
     WHEN sem_remocao THEN
        RAISE_APPLICATION_ERROR(-20101,'0 linhas removidas');
        
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20008, SQLCODE || ' -ERROR- ' || SQLERRM);

END remove_taxi;

-- Remove um motorista
PROCEDURE remove_motorista (nif_in IN motorista.nif%TYPE) IS

    sem_remocao EXCEPTION;

BEGIN
    -- Para cada viagem associada ao motorista, chama a procedure remove_viagem para as remover
    FOR viagens IN (SELECT motorista, inicio
                      FROM viagem V
                     WHERE V.motorista = nif_in) LOOP
        remove_viagem(viagens.motorista, viagens.inicio);
    END LOOP;
    
    -- Remove o motorista da tabela   
    DELETE FROM motorista WHERE nif = nif_in;
    
    -- Se nenhuma linha for removida, levanta uma excecao                                 
    IF (SQL%ROWCOUNT = 0) THEN
        RAISE sem_remocao;
    END IF;
          
EXCEPTION
    -- Trata excecoes especificas relacionadas a restricoes e gera mensagens de erro personalizadas
    WHEN sem_remocao THEN
        RAISE_APPLICATION_ERROR(-20101,'0 linhas removidas');
        
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20006, SQLCODE || ' -ERROR- ' || SQLERRM);
        
END remove_motorista;

-- Retorna uma lista de taxis mais conduzidos por um motorista
FUNCTION lista_taxis_mais_conduzidos(motorista_in IN motorista.nif%TYPE) 
                                    RETURN SYS_REFCURSOR IS

    c_taxis_total SYS_REFCURSOR;
    
BEGIN
    -- Abre um cursor para selecionar informacoes sobre taxis mais conduzidos pelo motorista    
    OPEN c_taxis_total FOR
        SELECT T.matricula, T.marca, T.conforto, Vin.minutos
               FROM (SELECT V.taxi, SUM (minutos_que_passaram(V.inicio, V.fim)) AS minutos
                    FROM viagem V
                    WHERE (V.motorista = motorista_in)
                    GROUP BY V.taxi) Vin,
                    taxi T
               WHERE Vin.taxi = T.matricula
               ORDER BY Vin.minutos ASC;
               
    -- Retorna o cursor contendo as informa��es               
    RETURN c_taxis_total;

END lista_taxis_mais_conduzidos;

END PKG_TAXI;