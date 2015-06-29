#!/bin/bash

RAIZ="$(dirname $0)"
ARQUIVO_CHANGELOG="CHANGELOG.md"
ARQUIVO_VERSAO="VERSION.txt"
TITULO_J="GEREPABA - Gerenciador de Releases para Bash"
EDITOR="vim"
cd "$RAIZ"


## Vamos ler a versão do arquivo, caso ele exista.
# Caso contrário, vamos sugerir 0.0.1. A mensagem
# exibida muda de acordo com a versão.
# Finalmente, gravamos o arquivo de versão.
if  [ -e "$ARQUIVO_VERSAO" ]
then 
  VERSAO="$(cat $ARQUIVO_VERSAO)"
  MENSAGEM="
  Detectei que você já usa versionamento.\n
  Coloquei a sua versão no campo abaixo\n 
  para que você a incremente como preferir.\n
  Além disso, coloquei as últimas tags do \n
  servidor remoto:
  
  $(git ls-remote --tags | grep -o 'refs/tags/.*' | cut -d '/' -f 3 | cut -b 2-) 
  
  "
else 
  VERSAO="0.0.1"
  MENSAGEM="
  Parece que você ainda não tem uma versão, 
  recomendo que você utilize algo sugestivo como 0.0.1.
  Edite a versão abaixo como preferir."
fi
VERSAO="$(dialog --title "$TITULO_J" --stdout --inputbox "$MENSAGEM" 0 0 "$VERSAO")"
echo "$VERSAO" > "${ARQUIVO_VERSAO}"


## A mensagem para o commit ou as tags é padronizada
TITULO="Release automatizado da versão v$VERSAO"


## Precisamos digitar um changelog
MENSAGEM="Seu editor de textos será aberto para que\n 
você crie um changelog em markdown ou txt.\n
Será aberto um arquivo modelo que pode ser\n
alterado livremente."
dialog --title "$TITULO_J" --msgbox "$MENSAGEM" 0 0


## Criamos um arquivo base, que é aberto no editor em seguida
cat > "${ARQUIVO_CHANGELOG}.new" <<EOF
# Changelog da Versão v$VERSAO
 
## Correções de erros
 * [] - 

## Melhorias
 * [] - 
 
## Novos recursos
 * [] - 
 
## Quebras de Interfaces Públicas
 * [] - 

-----------------------------------------------------------------------

EOF
$EDITOR "${ARQUIVO_CHANGELOG}.new"
cat "${ARQUIVO_CHANGELOG}" >> "${ARQUIVO_CHANGELOG}.new"
mv -f "${ARQUIVO_CHANGELOG}.new" "${ARQUIVO_CHANGELOG}"


## Para executar os comandos do git de forma padronizada
# a gente vai antes verificar se o usuário deseja realmente
# fazer isso.
MENSAGEM="
Os arquivos $ARQUIVO_CHANGELOG e $ARQUIVO_VERSAO foram gravados.
Posso executar os comandos abaixo?

git add --all .
git commit -m \"$TITULO\"
git tag -a \"v$VERSAO\" -m \"$TITULO\"

"
dialog --title "$TITULO_J" --yesno "$MENSAGEM" 0 0
if [ $? -eq 0 ]
then
  git add --all .
  git commit -m "$TITULO"
  git tag -a "v$VERSAO" -m "$TITULO"
fi


## Fim! :)
clear
echo "Boa! A tranquilidade não tem preço. 
Até o próximo release!!! ;-)"

