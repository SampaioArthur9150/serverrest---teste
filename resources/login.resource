*** Settings ***
Library    RequestsLibrary

*** Variables ***
${HOST}                https://serverest.dev
${LOGIN_ENDPOINT}       /login

*** Keywords ***
Criar Sessão
    Create Session    alias=serverest    url=${HOST}

Encerrar Sessão
    Delete All Sessions

Fazer Login
    [Arguments]    ${email}    ${password}    ${expected_status}=200

    &{headers}=    Create Dictionary    Content-Type=application/json
    &{body}=       Create Dictionary    email=${email}    password=${password}
    ${response}=   POST On Session    alias=serverest    url=${LOGIN_ENDPOINT}    headers=&{headers}    json=&{body}    expected_status=${expected_status}
    RETURN    ${response}

Verificar informações não cadastradas 
    [Arguments]    ${email}    ${senha}

    ${response}=    Fazer Login    email=${email}    password=${senha}    expected_status=401

    Log To Console    ${response.json()}
    Should Be Equal    ${response.json()['message']}    Email e/ou senha inválidos
    Should Be Equal As Strings    ${response.status_code}    401

Verificar campos obrigatórios do login
    [Arguments]    ${campo_vazio}    ${expected_msg}

    ${email}=    Set Variable   fulano@qa.com
    ${senha}=    Set Variable    teste

    IF    '${campo_vazio}' == 'email'
        ${email}=    Set Variable    ${EMPTY}
    ELSE IF    '${campo_vazio}' == 'senha'
        ${senha}=    Set Variable    ${EMPTY}
    END
        
    ${response}=    Fazer Login    email=${email}    password=${senha}     expected_status=400
    ${receveid_msg}=    Set Variable    ${response.json()}
    Log To Console    ${response.json()}   
    Should Be Equal As Strings    ${response.status_code}    400
    Should Be Equal As Strings    ${receveid_msg}    ${expected_msg}