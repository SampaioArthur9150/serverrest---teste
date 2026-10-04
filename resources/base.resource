*** Settings ***
Library    RequestsLibrary

*** Variables ***
${HOST}                https://serverest.dev

*** Keywords ***
Criar Sessão
    Create Session    alias=serverest    url=${HOST}

Encerrar Sessão
    Delete All Sessions