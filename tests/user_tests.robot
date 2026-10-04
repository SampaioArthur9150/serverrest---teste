*** Settings ***
Library    RequestsLibrary
Library    String
Resource   ../resources/base.resource
Resource    ../resources/users.resource
Suite Setup    base.Criar Sessão
Suite Teardown    base.Encerrar Sessão


*** Test Cases ***

Fluxo básico - Listar usuários
    ${response}=    Listar todos os usuários
    Log To Console    Status: ${response.status_code}
    Log To Console    Body: ${response.text}

Fluxo básico - Cadastrar novo usuário
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${email}=    Set Variable    testador${timestamp}@email.com
    ${senha}=    Set Variable    123456
    ${response}=    Criar um novo usuário    nome=Testador    email=${email}    senha=${senha}    permissao=false    expected_status=201
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}   Cadastro realizado com sucesso
    Should Be Equal As Strings    ${response.status_code}    201

Fluxo básico - Editar usuário
    ${id}    ${email}    ${senha}    ${nome}=    Criar usuário temporário e retornar o ID
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${novo_email}=    Set Variable    usuario${timestamp}@email.com
    ${response}=    Atualizar um usuário    id=${id}    nome=${nome}    email=${novo_email}    senha=${senha}    permissao=true    expected_status=200
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}    Registro alterado com sucesso
    Should Be Equal As Strings    ${response.status_code}    200

Fluxo básico - Deletar usuário
    ${id}    ${email}    ${senha}    ${nome}=    Criar usuário temporário e retornar o ID
    ${response}=    Deletar um usuário    id=${id}    
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}    Registro excluído com sucesso
    Should Be Equal As Strings    ${response.status_code}    200

[FE - 01] Cadastrar usuário com campo em branco
    Verificar campos obrigatórios    campo_vazio=nome    expected_msg={'nome': 'nome não pode ficar em branco'}

[FE - 02] Cadastrar usuário com email já existente
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${email}=    Set Variable    testador${timestamp}@email.com
    ${senha}=    Set Variable    123456
    ${response}=     Criar um novo usuário    nome=Testador    email=${email}    senha=${senha}    permissao=false    expected_status=201
    ${response2}=    Criar um novo usuário    nome=Testador    email=${email}    senha=${senha}    permissao=false    expected_status=400
    Log To Console    ${response2.json()}
    Should Be Equal As Strings    ${response2.status_code}    400
    Should Be Equal    ${response2.json()['message']}    Este email já está sendo usado

[FE - ]