*** Settings ***
Library    RequestsLibrary

*** Variables ***
${HOST}                https://serverest.dev
${LISTAR_USUARIOS}     /usuarios
${ADICIONAR_USUARIO}   /usuarios

*** Keywords ***

Listar todos os usuários
    ${response}=    GET On Session    alias=serverest    url=${LISTAR_USUARIOS}    expected_status=200
    RETURN    ${response}

Criar um novo usuário
    [Arguments]    ${nome}    ${email}    ${senha}    ${permissao}    ${expected_status}
    
    &{headers}=    Create Dictionary    Content-Type=application/json
    &{body}=       Create Dictionary    nome=${nome}    email=${email}    password=${senha}    administrador=${permissao}
    ${response}=   POST On Session    alias=serverest    url=${ADICIONAR_USUARIO}    headers=&{headers}    json=&{body}    expected_status=${expected_status}
    RETURN    ${response}

Atualizar um usuário
    [Arguments]    ${id}    ${nome}    ${email}    ${senha}    ${permissao}    ${expected_status}=200
    &{headers}=    Create Dictionary    Content-Type=application/json
    &{body}=       Create Dictionary    nome=${nome}    email=${email}    password=${senha}    administrador=${permissao}
    ${response}=   PUT On Session    alias=serverest    url=/usuarios/${id}    headers=&{headers}    json=&{body}    expected_status=${expected_status}
    RETURN    ${response}

Deletar um usuário
    [Arguments]    ${id}    ${expected_status}=200
    ${response}=   DELETE On Session    alias=serverest    url=/usuarios/${id}    expected_status=${expected_status}
    RETURN    ${response}

Criar usuário temporário e retornar o ID
    [Documentation]    Cria um usuário temporário e retorna o ID 
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${nome}=    Set Variable    Usuário Teste    
    ${email}=    Set Variable    usuario${timestamp}@email.com
    ${senha}=    Set Variable    teste
    ${response}=    Criar um novo usuário    nome=${nome}    email=${email}    senha=${senha}    permissao=true    expected_status=201
    ${id}=    Set Variable    ${response.json()['_id']}
    RETURN    ${id}    ${nome}    ${email}    ${senha}

Verificar campos obrigatórios
    [Arguments]    ${campo_vazio}    ${expected_msg}

    ${nome}=    Set Variable    Usuário
    ${email}=    Set Variable   usuario@email.com
    ${senha}=    Set Variable    teste

    IF    '${campo_vazio}' == 'nome'
        ${nome}=    Set Variable    ${EMPTY}
    ELSE IF    '${campo_vazio}' == 'email'
        ${email}=    Set Variable    ${EMPTY}
    ELSE IF    '${campo_vazio}' == 'senha'
        ${senha}=    Set Variable    ${EMPTY}
    END
        
 
    ${response}=    Criar um novo usuário    nome=${nome}    email=${email}    senha=${senha}    permissao=true    expected_status=400

    ${receveid_msg}=    Set Variable    ${response.json()}
    Log To Console    ${response.json()}   
    Should Be Equal As Strings    ${response.status_code}    400
    Should Be Equal As Strings    ${receveid_msg}    ${expected_msg}