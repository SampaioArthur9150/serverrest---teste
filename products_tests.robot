*** Settings ***
Library  RequestsLibrary
Library  String
Resource  ../resources/base.resource
Resource  ../resources/products.resource
Suite Setup  base.Criar Sessão
Setup Teardown  base.Encerrar Sessão

*** Test Cases ***

Fluxo básico - Listar produtos
    ${response}=    Listar todos os produtos
    Log to Console    Status: ${response.status_code}
    Log to Console    Body: ${response.text}

Fluxo básico - Cadastrar produto
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${email}=    Set Variable    testeuser${timestamp}@test.com
    ${senha}=    Set Variable    teste123
    ${response_criar}=    Criar usuário    nome=Usuário Teste    email=${email}    senha=${senha}    permissao=true
    ${token}=    Fazer login    ${email}    ${senha}
    ${produto_nome}=    Set Variable    Produto Teste ${timestamp}
    ${response}=    Cadastrar um novo produto    ${token}    ${produto_nome}    ${111}    Item    ${4444}    
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}    Cadastro realizado com sucesso
    Should Be Equal As Strings    ${response.status_code}    201

Fluxo básico - Editar produto
    ${token}    ${user_id}    ${nome}    ${email}    ${senha}=    Criar usuário temporário e retornar token
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${produto_nome}=    Set Variable    Produto Teste 2 ${timestamp}
    ${response_cadastro}=    Cadastrar um novo produto    token=${token}    nome=${produto_nome}    preco=${3600}    descricao=Produto    quantidade=8999    expected_status=201
    ${produto_id}=    Set Variable    ${response_cadastro.json()['_id']}
    ${novo_nome}=    Set Variable    Produto Editado ${timestamp}
    ${response}=    Editar um produto    token=${token}    id=${produto_id}    nome=${novo_nome}    preco=${3600}    descricao=Produto Editado    quantidade=67    expected_status=200
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}    Registro alterado com sucesso
    Should Be Equal As Strings    ${response.status_code}    200

Fluxo básico - Deletar produto
    ${token}    ${user_id}    ${nome}    ${email}    ${senha}=    Criar usuário temporário e retornar token
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${produto_nomme}=    Set Variable    Produto Teste 3 ${timestamp}
    ${response_cadastro}=    Cadastrar um novo produto    token=${token}    nome=${produto_nomme}    preco=${3600}    descricao=Produto    quantidade=74    expected_status=201
    ${produto_id}=    Set Variable    ${response_cadastro.json()['_id']}
    ${response}=    Deletar um produto    ${token}    id=${produto_id}    expected_status=200
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}    Registro excluído com sucesso
    Should Be Equal As Strings    ${response.status_code}    200

[FE - 01] Cadastrar produto sem token
    ${response}=    Cadastrar um novo produto    {token}    nome=teclado 80%    preco=200    descricao=teclado    quantidade=88    expected_status=401
    ${msg}=    Set Variable    ${response.json()['message']}
    Log to Console    ${response.json()}
    Should Be Equal    ${msg}    Token de acesso ausente, inválido, expirado ou usuário do token não existe mais
    Should Be Equal As Strings    ${response.status_code}    401

[FE - 02] Cadastrar produto com campo em branco
    ${token}    ${user_id}    ${nome}    ${email}    ${senha}=    Criar usuário temporário e retornar token
    ${response}=    Cadastrar um novo produto    token=${token}    nome=${EMPTY}    preco=80    descricao=produto    quantidade=75    expected_status=400
    ${msg}=    Set Variable    ${response.json()}
    Log to Console    ${response.json()}
    Should Be Equal As Strings   ${msg}    {'nome': 'nome não pode ficar em branco'}
    Should Be Equal As Strings    ${response.status_code}    400

[FE - 03] Deletar produto com token ausente
    ${token}    ${user_id}    ${nome}    ${email}    ${senha}=    Criar usuário temporário e retornar token
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${produto_nomme}=    Set Variable    Produto Teste 3 ${timestamp}
    ${response_cadastro}=    Cadastrar um novo produto    token=${token}    nome=${produto_nomme}    preco=${3600}    descricao=Produto    quantidade=74    expected_status=201
    ${produto_id}=    Set Variable    ${response_cadastro.json()['_id']}
    ${response}=    Deletar um produto    ${EMPTY}    id=${produto_id}    expected_status=401
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}    Token de acesso ausente, inválido, expirado ou usuário do token não existe mais
    Should Be Equal As Strings    ${response.status_code}    401

[FE - 04] Editar produto com token ausente
    ${token}    ${user_id}    ${nome}    ${email}    ${senha}=    Criar usuário temporário e retornar token
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${produto_nome}=    Set Variable    Produto Teste 2 ${timestamp}
    ${response_cadastro}=    Cadastrar um novo produto    token=${token}    nome=${produto_nome}    preco=${3600}    descricao=Produto    quantidade=8999    expected_status=201
    ${produto_id}=    Set Variable    ${response_cadastro.json()['_id']}
    ${novo_nome}=    Set Variable    Produto Editado ${timestamp}
    ${response}=    Editar um produto    token=${EMPTY}    id=${produto_id}    nome=${novo_nome}    preco=${3600}    descricao=Produto Editado    quantidade=67    expected_status=401
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}    Token de acesso ausente, inválido, expirado ou usuário do token não existe mais
    Should Be Equal As Strings    ${response.status_code}    401

[FE - 05] Cadastrar produto já existente
    ${token}    ${user_id}    ${nome}    ${email}    ${senha}=    Criar usuário temporário e retornar token
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${produto_nome}=    Set Variable    Notebook Asus ${timestamp}
    Cadastrar um novo produto    token=${token}    nome=${produto_nome}    preco=3500    descricao=Notebook    quantidade=45    expected_status=201
    ${response}=    Cadastrar um novo produto    token=${token}    nome=${produto_nome}    preco=3500    descricao=Notebook    quantidade=45    expected_status=400
    ${msg}=    Set Variable    ${response.json()['message']}
    Log To Console    ${response.json()}
    Should Be Equal    ${msg}    Já existe produto com esse nome
    Should Be Equal As Strings    ${response.status_code}    400

[FE - 06] Cadastrar produto com preco em decimal
    ${timestamp}=    Evaluate    int(time.time() * 1000)    modules=time
    ${email}=    Set Variable    testeuser${timestamp}@test.com
    ${senha}=    Set Variable    teste123
    ${response_criar}=    Criar usuário    nome=Usuário Teste    email=${email}    senha=${senha}    permissao=true
    ${token}=    Fazer login    ${email}    ${senha}
    ${response}=    Cadastrar um novo produto    ${token}    nome=Produto Teste${timestamp}    preco=1.200    descricao=Item    quantidade=4444    expected_status=400       
    ${msg}=    Set Variable    ${response.json()}
    Log To Console    ${response.json()}
    Should Be Equal As Strings   ${msg}    {'preco': 'preco deve ser um inteiro'}
    Should Be Equal As Strings    ${response.status_code}    400