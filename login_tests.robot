*** Settings ***
Library  RequestsLibrary
Library  String
Resource  ../resources/base.resource
Resource  ../resources/login.resource
Suite Setup    base.Criar Sessão
Suite Teardown    base.Encerrar Sessão
*** Test Cases ***

Fluxo básico - Realizar login
    ${response}=    login.Fazer Login    email=testeuser1791135908280@test.com    password=teste123    expected_status=200
    Log to Console  ${response.text}
    Should Be Equal As Strings  ${response.status_code}  200

[FE - 01] Realizar login com email vazio
    Verificar campos obrigatórios do login    campo_vazio=email    expected_msg={'email': 'email não pode ficar em branco'}

[FE - 02] Realizar login com senha vazia
    Verificar campos obrigatórios do login    campo_vazio=senha    expected_msg={'password': 'password não pode ficar em branco'}

[FE - 03] Realizar login com campo não cadastrado
    Verificar informações não cadastradas    email=semcadastro@qa.com    senha=teste