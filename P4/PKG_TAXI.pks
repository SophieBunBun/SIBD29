create or replace PACKAGE PKG_TAXI IS 
-- SIBD 2023/2024, Etapa 4, Grupo 29
-- Miguel Simoes 60451 TP1?
-- Nuno Graxinha 59855 TP15
-- Sofia Santos 59804 TP15

-- Excecao Mensagem
-- -20002 Taxi ou motorista ja registados com outra viagem cujo 
--        tempo em que decorre interseta a introduzida
-- -20004 Motorista deve ter idade igual ou superior a 18 anos
-- -20011 O valor de algum parametro introduzido em taxi nao pode ser null
-- -20012 O valor de algum parametro introduzido em motorista nao pode ser null
-- -20103 O valor de algum parametro introduzido em viagem nao pode ser null
-- -20104 Motorista e inicio nao podem ser null ou tem de ser diferente de viagens existentes
-- -20105 Motorista deve existir
-- -20106 Taxi deve existir
-- -20107 Inicio tem de ser menor que fim
-- -20108 A viagem so pode ter entre 1 a 8 passageiros
-- -20111 matricula nao pode ser null ou tem de ser diferente de matriculas existentes
-- -20112 nif nao pode ser null ou tem de ser diferente de nif existentes
-- -20211 matricula tem de ter 6 caracteres
-- -20212 nif tem de ser entre 100000000 e 999999999
-- -20311 ano superior a 1900
-- -20312 genero tem de ser F ou M
-- -20411 conforto tem de ser B ou L
-- -20412 nascimento tem de ser superior a 1900
-- -20511 eurosminuto tem de ser maior que zero

-- Regista um novo motorista
PROCEDURE regista_motorista (nif_in        IN motorista.nif%TYPE,
                              nome_in       IN motorista.nome%TYPE,
                             genero_in     IN motorista.genero%TYPE,
                             nascimento_in IN motorista.nascimento%TYPE,
                             localidade_in IN motorista.localidade%TYPE);

-- Registra um novo taxi
PROCEDURE regista_taxi(matricula_in   IN taxi.matricula%TYPE,
                       ano_in         IN taxi.ano%TYPE,
                       marca_in       IN taxi.marca%TYPE,
                       conforto_in    IN taxi.conforto%TYPE,
                       eurosminuto_in IN taxi.eurosminuto%TYPE); 

-- Registra uma nova viagem
PROCEDURE regista_viagem (motorista_in   IN motorista.nif%TYPE,
                          inicio_in      IN DATE,
                          fim_in         IN DATE,
                          taxi_in        IN taxi.matricula%TYPE,
                          passageiros_in IN viagem.passageiros%TYPE);

-- Remove uma viagem                       
PROCEDURE remove_taxi(matricula_in IN taxi.matricula%TYPE);

-- Remove um taxi                        
PROCEDURE remove_viagem (motorista_in IN motorista.nif%TYPE,
                         data_in      IN DATE);

-- Remove um motorista    
PROCEDURE remove_motorista (nif_in IN motorista.nif%TYPE);
        
-- Retorna uma lista de taxis mais conduzidos por um motorista                         
FUNCTION lista_taxis_mais_conduzidos(motorista_in IN motorista.nif%TYPE) 
                                    RETURN SYS_REFCURSOR;

END PKG_TAXI;