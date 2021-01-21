.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern scanf: proc
extern printf: proc
extern sscanf:proc
extern strcpy:proc
extern strcmp:proc
extern strchr:proc
extern putchar:proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
expresie db 100 dup(0)

expresie_format db "%s" ,0 
charachter db "%c" ,0
intreg db "%d" ,13,10,0
print_rezultat db "=%d", 13,10,0
printf_exp db "> %s",13,10,0
printf_intr_exp db "> Introduceti o expresie:" ,13,10,0
exit_loop db "exit",0
sscanfstring db "%c%d%c",13,10,0

val_verif db 0

adunare db "+",0
scadere db "-",0
inmultire db "*",0
impartire db "/",0
semn_egal db "=",0
impartire_rest db "%",0

semn_egal_char dd '='
adunare_char db '+'
scadere_char db '-'
inmultire_char db '*'
impartire_char db '/'
rest_char db '%'

ope1 dd 0
ope2 dd 0
opnd1 dd 0
opnd2 dd 0
opnd3 dd 0
poz0 db 0
op_pe_poz_0 db 0

print_error db"> Impartiroul/divizorul nu poate fi 0!!!",13,10,0
print_exit db "> Calculatorul se opreste!!!",13,10,0
print_bad_exp db "> Expresie incorecta!!!",13,10,0

lenght dd 0
rezultat dd 0

strcpy_nr dd 0
egal_nr dd 0
.code

operatie proc
	push ebp
	mov ebp,esp
	mov ebx, [ebp+16]
	push ebx
	xor eax,eax
	
	push ebx
	push offset adunare
	call strcmp
	add ESP,8
	cmp eax, 0
	je op_adunare
	
	push ebx
	push offset scadere
	call strcmp
	add ESP,8
	cmp eax, 0
	je op_scadere
	
	push ebx
	push offset inmultire
	call strcmp
	add ESP,8
	cmp eax, 0
	je op_inmultire
	
	push ebx
	push offset impartire
	call strcmp
	add ESP,8
	cmp eax, 0	
	je op_impartire
	
	push ebx
	push offset impartire_rest
	call strcmp
	add ESP,8
	cmp eax, 0	
	je op_impartire_rest
	
op_adunare:
xor eax,eax
mov ebx,[ebp+12]
mov ecx,[ebp+8]
add eax,ebx
add eax,ecx
jmp final

op_scadere:
xor eax,eax
mov ebx,[ebp+12]
mov ecx,[ebp+8]
add eax, ecx
sub eax,ebx
jmp final

op_inmultire:
xor eax,eax
xor edx,edx
mov ebx,[ebp+12]
mov ecx,[ebp+8]
mov eax, ecx
mul ebx
jmp final

op_impartire:
xor eax,eax
xor edx,edx
mov ebx,[ebp+12]
mov ecx,[ebp+8]
mov eax,ecx
cmp ebx,0
je final_error
div ebx
jmp final

op_impartire_rest:
xor eax,eax
xor edx,edx
mov ebx,[ebp+12]
mov ecx,[ebp+8]
mov eax,ecx
cmp ebx,0
je final_error
div ebx
mov eax,edx
jmp final

final_error:
push offset print_error
call printf 
add ESP,4
jmp loop_citire

final:
mov esp, ebp
	pop ebp
	ret 12
operatie endp

nr_cif proc
	push ebp
	mov ebp,esp
	mov ebx,10
	mov esi,0
	mov eax,[ebp+8]
	while_mai_mare:
		xor edx,edx
		inc esi
		div ebx
		cmp eax,0
		jne while_mai_mare
	mov eax,esi
	mov esp,ebp
	pop ebp
	ret 4
	
nr_cif endp	


start:
	
	
	;aici se scrie codul
	loop_citire:
	push offset printf_intr_exp
	call printf
	add ESP,4
	
	;citim stringul
	push offset expresie
	push offset expresie_format
	call scanf
	add ESP,8
	
	;verificam daca stringul nu este exit
	push offset expresie
	push offset exit_loop
	call strcmp
	add ESP,8
	
	mov val_verif,al
	
	;daca stringul este "exit" atunci calculator se oprestes
	cmp val_verif,0
	je stop_calc
	
	mov op_pe_poz_0,0
	
	;verificam daca in expresia introdusa exista un caracter de '=', daca nu atunci inseamna ca expresia e incorecta
	push semn_egal_char
	push offset  expresie
	call strchr
	add ESP,8

	cmp eax,0
	je printf_error
	jmp no_printf_error
	printf_error:
	push offset print_bad_exp
	call printf
	add ESP,4
	jmp loop_citire
	no_printf_error:
	
	;verificam daca primul caracter din sir este un semne de operatie sau un numar
	mov bl,expresie[0]
	cmp bl, adunare_char
	je primul_element_operatie
	cmp bl, scadere_char
	je primul_element_operatie
	cmp bl, inmultire_char
	je primul_element_operatie
	cmp bl,impartire_char
	je primul_element_operatie
	cmp bl, rest_char
	je primul_element_operatie
	
	jmp p_e_o_no 
	
	primul_element_operatie:
	mov op_pe_poz_0,1 ; in aceasta variabila memoram daca primul caracter din string este semn sau nr, variabile este =1 , daca este semn si 0 in caz contrar
	p_e_o_no:
	
;calculator!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	mov strcpy_nr,0
	mov lenght,0
	mov egal_nr,0
	
	cmp op_pe_poz_0, 1
	jne citeste_primul_operand
	mov eax, rezultat
	mov opnd1, eax
	jmp nu_citeste_primul_operand
	citeste_primul_operand:
	push offset opnd1
	push offset intreg
	push offset expresie
	call sscanf
	add ESP,12
	
	push opnd1
	call nr_cif
	add lenght,eax

	
	loop_strcpy:
	dec lenght
	push offset [expresie+1]
	push offset expresie
	call strcpy
	add ESP,8
	cmp lenght,0
	jne loop_strcpy
	cmp strcpy_nr,1
	je f_strcpy1
	cmp strcpy_nr,2
	je f_strcpy2
	
	nu_citeste_primul_operand:
	mov lenght,0
	
	push offset ope2
	push offset opnd2
	push offset ope1
	push offset sscanfstring
	push offset expresie
	call sscanf
	add ESP,20
	
	push opnd2
	call nr_cif
	add lenght,eax
	add lenght,2
	
	mov strcpy_nr, 1
	jmp loop_strcpy
	f_strcpy1:
	
	mov ebx, ope1
	cmp ebx, semn_egal_char
	jne n_afisare
	mov eax,opnd1
	mov rezultat,eax
	jmp afisare_rezultat
	n_afisare:
	
	if_egal:
		xor ebx,ebx
		mov ebx, ope2
		cmp ebx, semn_egal_char
		jne n_citire_opnd3
		push offset ope1
		push opnd2
		push opnd1
		call operatie
		mov rezultat, eax
		jmp afisare_rezultat
		
		n_citire_opnd3:
		push offset opnd3
		push offset intreg
		push offset expresie
		call sscanf
		add ESP,12
		mov lenght,0
		
		push opnd3
		call nr_cif
		add lenght,eax
		mov strcpy_nr,2
		jmp loop_strcpy
		f_strcpy2:
		
		cmp egal_nr,1
		je f_egal1
		cmp egal_nr,2
		je f_egal2
		
	loop_parcurgere_string:
		
		;verificam daca prima operatie este inmultire sau impartire
		mov ebx, ope1
		cmp bl, inmultire_char
		je executam_prima_op
		cmp bl, impartire_char
		je executam_prima_op
		cmp bl, rest_char
		je executam_prima_op
		jmp verif_a_doua_op
		
		executam_prima_op:
		push offset ope1
		push opnd2
		push opnd1
		call operatie
		mov opnd1,eax
		mov eax, ope2
		mov ope1,eax
		mov eax,opnd3
		mov opnd2,eax
		
		push offset ope2
		push offset charachter
		push offset expresie
		call sscanf
		add ESP,12
		
		push offset expresie+1
		push offset expresie
		call strcpy
		add ESP,8
		
		mov egal_nr,1
		jmp if_egal
		f_egal1:
		
		;verificam pe a doua operatie daca este inmultire sau impartire
		verif_a_doua_op:
		mov ebx, ope2
		cmp bl, inmultire_char
		je executam_a_doua_op
		cmp bl,impartire_char
		je executam_a_doua_op
		cmp bl,rest_char
		je executam_a_doua_op
		jmp executam_prima_op
		
		executam_a_doua_op:
		push offset ope2
		push opnd3
		push opnd2
		call operatie
		mov opnd2,eax
		
		push offset ope2
		push offset charachter
		push offset expresie
		call sscanf
		add ESP,12
		
		push offset expresie+1
		push offset expresie
		call strcpy
		add ESP,8
		
		mov egal_nr,2
		jmp if_egal
		f_egal2:
		
	jmp loop_parcurgere_string
	afisare_rezultat:
		push rezultat
		push offset print_rezultat
		call printf
		add ESP,8
	jmp loop_citire
	;terminarea programului
	stop_calc:
	
	push offset print_exit
	call printf
	add ESP,4
	push 0
	call exit
end start
