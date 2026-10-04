*** Settings ***
Library    RequestsLibrary

*** Variables ***
${HOST}                https://serverest.dev
${LISTAR_PRODUTOS}     /produtos
${ADICIONAR_PRODUTO}   /produtos

*** Keywords ***

Listar todos os produtos
    ${response}=    GET On Session    alias=serverest    url=${LISTAR_PRODUTOS}    expected_status=200
    RETURN    ${response}

Criar usuário
    [Arguments]    ${nome}    ${email}    ${senha}    ${permissao}    ${expected_status}=201
    &{headers}=    Create Dictionary    Content-Type=application/json
    &{body}=    Create Dictionary    nome=${nome}    email=${email}    password=${senha}    administrador=${permissao}
    ${response}=    POST On Session    alias=serverest    url=/usuarios    headers=&{headers}    json=&{body}    expected_status=${expected_status}
    RETURN    ${response}

Fazer login
    [Arguments]    ${email}    ${senha}    ${expected_status}=200
    &{headers}=    Create Dictionary    Content-Type=application/json
    &{body}=    Create Dictionary    email=${email}    password=${senha}
    ${response}=    POST On Session    alias=serverest    url=/login    headers=&{headers}    json=&{body}    expected_status=${expected_status}
    ${token}=    Set Variable    ${response.json()["authorization"]}
    RETURN    ${token}

Cadastrar um novo produto
    [Arguments]    ${token}    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${expected_status}=201
    &{headers}=    Create Dictionary    Content-Type=application/json    authorization=${token}
    &{body}=    Create Dictionary    nome=${nome}    preco=${preco}    descricao=${descricao}    quantidade=${quantidade}
    ${response}=    POST On Session    alias=serverest    url=${ADICIONAR_PRODUTO}    headers=&{headers}    json=&{body}    expected_status=${expected_status}
    RETURN    ${response}

Editar um produto
    [Arguments]    ${token}    ${id}    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${expected_status}=200
    &{headers}=    Create Dictionary    Content-Type=application/json    authorization=${token}
    &{body}=    Create Dictionary    nome=${nome}    preco=${preco}    descricao=${descricao}    quantidade=${quantidade}
    ${response}=    PUT On Session    alias=serverest    url=/produtos/${id}    headers=&{headers}    json=&{body}    expected_status=${expected_status}
    RETURN    ${response}

Deletar um produto
    [Arguments]    ${token}    ${id}    ${expected_status}=200
    &{headers}=    Create Dictionary    Content-Type=application/json    authorization=${token}
    ${response}=    DELETE On Session    alias=serverest    url=/produtos/${id}    headers=&{headers}    expected_status=${expected_status}
    RETURN    ${response}    

Criar usuário temporário e retornar token
    [Documentation]    Cria um usuário temporário e retorna token
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${nome}=    Set Variable    Usuário Teste
    ${email}=    Set Variable    usuario${timestamp}@email.com
    ${senha}=    Set Variable    teste
    ${response}=    Criar usuário    nome=${nome}    email=${email}    senha=${senha}    permissao=true    expected_status=201
    ${id}=    Set Variable    ${response.json()['_id']}
    ${token}=    Fazer login    email=${email}    senha=${senha}    expected_status=200
    RETURN    ${token}    ${id}    ${nome}    ${email}    ${senha}