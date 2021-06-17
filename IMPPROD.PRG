set date brit
set excl       off
set delete     on
set wrap       on
set scoreboard off
set status     off
SET( _SET_DATEFORMAT , "DD/MM/YYYY" )
SET( _SET_EPOCH      , 1915         )
scroll()
//--------------------------------------------------------
// Programa  : IMPPROD.PRG
// Autor     : Walter A. Vianna Filho
// Date      : Junho, 17 de 2021
// Descricao : Desafio Técnico - Prova de Clipper
//--------------------------------------------------------

/* 1) Crie uma função que abre o arquivo na pasta “X:\ISPB\Produtos” e leia cada linha do
   arquivo em um loop, separando os dados das colunas em variáveis.
   
   2) Crie uma função que recebe cada linha do arquivo lido na função anterior e atualiza o
   registro na tabela abaixo, considerando que a coluna “Código ISPB” é a chave única da
   tabela (não pode criar registros com o código duplicado, mas pode gravar a
   desativação do produto já existente)   
*/

close databases

@ 02,00 clear to 02,80
@ 02,01 say "PROCESSA ARQUIVO" COLOR "W+/N"
scroll(03,00,21,80)

@ 00,69 say date()
@ 01,69 say time()
scroll(03,00,21,80)

LeArquivo()

Function LeArquivo()
	cls
	buffer = space(32)
	Handle = FOPEN("X:\ISPB\Produtos\Produtos.txt"
	
	do while FREAD(Handle,@buffer,32) = 32

	   mCODISPB    := substr(buffer,1,8)
	   mCODBANCO   := substr(buffer,9,3)
	   mCODPRODUTO := substr(buffer,12,4)
	   mINDSITUA   := substr(buffer,16,1)
	   mDATATIVA   := ctod(substr(buffer,23,2)+"/"+substr(buffer,21,2)+"/"+substr(buffer,17,4))
	   mDATDESATIV := ctod(substr(buffer,31,2)+"/"+substr(buffer,29,2)+"/"+substr(buffer,25,4))
	   
	   AtualizaArquivo(pODISPB, pCODBANCO, pCODPRODUTO, pINDSITUA, pDATATIVA, pDATDESATIV)
	   
	enddo
	FCLOSE(Handle)
Return
	   
Function AtualizaArquivo()

	   SELE 1
	   if .not. net_use("ProdISPB",.f.,5)
	      ? "Arquivo Bloqueado"
	      return
	   else
	      set index to Prod01   
	   endif
	   ? mCODISPB + " " + mCODBANCO + " " + mCODPRODUTO + " " + mINDSITUA + " " + mDATATIVA+ " " + mDATDESATIV
		
	   SELE 1
	   SET ORDER TO 1
	   seek mCODISPB
	   
	   if found()
		 if .not. rec_lock(5)
			bloqlock()
		 endif
	     repl DATDESATIV with mDATDESATIV
		 unlock
		 
	   else
		  if .not. add_rec(5)
			 bloqadd()
		  endif	   
  		  repl CODISPB    with mCODISPB
		  repl CODBANCO   with mCODBANCO
		  repl CODPRODUTO with mCODPRODUTO
		  repl INDSITUA   with mINDSITUA
		  repl DATATIVA   with mDATATIVA
		  repl DATDESATIV with mDATDESATIV
		  unlock
	 
	   endif
	   SET ORDER TO

Return

func bloqadd
   do while .t.
      @ 23,00 clear
      @ 23,01 say "Registro Bloqueado! Tenta Novamente (S/N) ? "
      ok = "S"
      @ 23,col() get ok pict "@!" $"S,N"
      read
      @ 23,00 clear
      if upper(ok) = "S"
         if .not. add_rec(5)
            loop
         endif
      else
         close databases
         quit
      endif
      exit
   enddo
return

func bloqlock
   do while .t.
      @ 23,00 clear
      @ 23,01 say "Registro Bloqueado! Tenta Novamente (S/N) ? "
      ok = "S"
      @ 23,col() get ok pict "@!" $"S,N"
      read
      @ 23,00 clear
      if upper(ok) = "S"
         if .not. rec_lock(5)
            loop
         endif
      else
         close databases
         quit
      endif
      exit
   enddo
return