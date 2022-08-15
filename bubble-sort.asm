.data
stringIngresoFrase: .asciiz  "\n\nIngrese los caracteres: "  # Texto inicial que indica para guardar la frase
newLine: .asciiz "\n"                               # Caracter especial para bajar de linea
stringGuardado: .asciiz ""                   			# String donde se va a guardar la frase 
#stringSeparador: .asciiz "\n\nIngrese el separador:"   #Texto inicial que se muestra antes del separador
#stringSeparadorGuardado: .asciiz ""   #String donde se va a guardar el separador


##TODO: 1. Ingresa un archivo llamado sentences.txt que tiene el valor de las frases en vez de ingresarlo manualmente.
##TODO: 2. Que se ingrese el string separador.
##TODO: 3. Que no sea caracter a caracter, sino a frases validando el caracter separador.
##TODO: 4. Generar un output.txt donde se imprima cada frase con un salto de linea entre frases.

.text 
main:
    la $a0, stringIngresoFrase   # Carga la dirección de stringIngreso en $a0
    li $v0, 4        # Ahora se muestra por pantalla
    syscall          # Se llama al sistema para mostrar

    la $a0,stringGuardado  # Carga el input digitado en stringGuardado
    li $a1,256         # TAMAÑO MÁXIMO DEL STRING
    li $v0,8          # Lee el string
    syscall

    li $s7,256          # Tamaño del string (Para validar en los loops)

    jal uppercase  
    jal sort
    jal print
    j exit


#Este metodo guarda todo en memoria.
uppercase:

    la $s0, stringGuardado    # Guarda en la variable $s0 la dirección del string guardado
    add $t6,$zero,$zero  # Ahora I = 0 para comenzar con el loop 
    lupper:
        beq $t6,$s7,done   #  Ahora, se mira si ya se recorrió todo el string, si no, palante

        #  Cargamos el valor de vector[I]
        add $s2,$s0,$t6 #Se da la dirección del valor actual 
        lb  $t1,0($s2) # Se carga el valor de la dirección actual 
        sgt  $t2,$t1,96 #Su es mayor a 96
        slti $t3,$t1,95 #Si es menor a 95
        and $t3,$t2,$t3 #Se mandaría un 1 si ambas son verdaderas
        beq $t3,$zero,isUpper #si es verdadera, no se le resta para que entre en las minusculas
        addi $t1,$t1,-32 #Si es falsa, entonces s ele resta para que sea mayuscula
        sb   $t1, 0($s2) #Y luego se guarda el nuevo bit con el Save Bit
        isUpper:
        addi $t6,$t6,1 #Se incrementa el contador y continua
        j lupper

#BubbleSort
sort:   
    add $t0,$zero,$zero #  Se reinicia el contador

    loop:                
        beq $t0,$s7,done  #  Se mira si ya se recorrió el string completo

        sub $t7,$s7,$t0 #Se resta el valor máximo, menos el contador y se guarda en $t7
        addi $t7,$t7,-1 #Y luego se le resta 1

        add $t1,$zero,$zero #Se inicializa el contador de el loop interno

        loopInterno:
            beq $t1,$t7,continuar #Miramos si ya se recorrió todo el string (Menos uno y menos el $t0, que indica las pocisiones que ya están ordenadas)
            #Ahora cargamos los valores que vamos a comparar (I y I+1)
            add $t6,$s0,$t1 #Acá está la dirección del vector y I
            lb  $s1,0($t6) #Acá se lleva vector[i]
            lb  $s2,1($t6) #Acá se lleva vector [i+1]
            sgt $t2, $s1,$s2 #Si vector[i] > vector[i+i] entonces arroja true, si no, arroja false
            beq $t2, $zero, false #Si es false entonces no se intercambia y se sigue con el siguiente número.
            sb  $s2,0($t6) #Si es true, entonces se continua y se le mete el bit de $t6 a $s2
            sb  $s1,1($t6) #y se le mete el $t6+1 a $s1
            false:
            addi $t1,$t1,1 #Se le suma uno al contador interno
            j loopInterno

        continuar:
        addi $t0,$t0,1 #Se le suma uno al contador externo
        j loop

#Procedimiento para imprimir
print:
    # Salto de linea para que quede la solución bajo la pregunta
    la $a0,newLine 
    li $v0,4
    syscall 
	#Ahora, para imprimir el string se crea un loop
    add $t6,$zero,$zero # Se pone el valor del contador en 0

    loopPrint:
        beq $t6,$s7,done  #Se mira si ya recorrió todo el string
        add $t1,$s0,$t6 #Se trae la dirección del valor a imprimir
        lb $a0, 0($t1)  # Se carga lo que se va a imprimir
        li $v0, 11      # Se carga el código para imprimir por pantalla
        syscall         # Se llama al sistema
        la $a0,newLine #Se ejecuta un salto de linea
   	li $v0,4	#Se imprime
   	syscall	#Se llama al sistema
        addi $t6,$t6,1  #Se le suma uno al contador y vuelve al loop
        j loopPrint

#Acá se devuelve al loop anterior.
done:
    jr $ra
    
#Finaliza la app
exit:
	
