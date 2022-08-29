.data
stringSeparador: .asciiz "\n\nIngrese el separador: "			#Texto inicial que se muestra antes del separador
stringSeparadorGuardado: .space 2000 				#String donde se va a guardar el separador
stringIngresoFrase: .asciiz  "\n\nIngrese los caracteres: "  	# Texto inicial que indica para guardar la frase
newLine: .asciiz "\n"                               		# Caracter especial para bajar de linea
stringGuardado: .space 2000                   			# String donde se va a guardar la frase 
stringOrdenar: .space 2000					#String donde se va a guardar la frase separador


##TODO: 3. Que el ordenamiento no sea caracter a caracter, sino una frase.
##TODO: 4. Que las frases se separen las frases con un caracter separador.


## Crear el array con las direcciones de memorias de las frases. Luego ordenar cada frase con un metodo llamado Swap
## 
.text 
main:
	jal saveStringIngreso 	#Pide el valor de ingreso
	jal saveSeparador 	#Pide el separador de las frases
	jal saveMemory 		#Guarda el separador en memoria
	jal saveMemoryString 	#Guarda en memoria el valor de ingreso
	jal bubbleSort 		#Ordena las frases ingresadas
	jal print 		#Imprime por consola el valor ordenado
	j exit 			#Finaliza la aplicación

saveStringIngreso:
    la $a0, stringIngresoFrase  # Carga la dirección de stringIngreso en $a0
    li $v0, 4       		# Ahora se muestra por pantalla
    syscall          		# Se llama al sistema para mostrar

    la $a0,stringGuardado  	# Carga el input digitado en stringGuardado
    li $a1,10        		# TAMAÑO MÁXIMO DEL STRING
    li $v0,8          		# Lee el string
    syscall
    
    li $s7,10        		# Tamaño del string (Para validar en los loops)
    j done


saveSeparador:
	la $a0, stringSeparador  # Carga la dirección de stringSeparador en $a0
	li $v0, 4      		 # Ahora se muestra por pantalla
	syscall          	# Se llama al sistema para mostrar

	la $a0,stringSeparadorGuardado  # Carga el input digitado en stringSeparadorGuardado
	li $a1,2      			# TAMAÑO MÁXIMO DEL STRING (De momento solo tendrá un string)
	li $v0,8         		# Lee el string
	syscall
	    
	j done

#Guardar el separador en la dirección de $S3
saveMemory:
	la $s3, stringSeparadorGuardado
	j done


#Este metodo guarda todo el string en $S0 
saveMemoryString:
        la $s0, stringOrdenar 		#Dirección del string a ordenar
        la $t3, stringOrdenar		#Dirección del string a ordenar
        la $t2, stringGuardado		#Dirección del string guardado
        add $t6, $zero, $zero		#Contador = 0
        loopMemoryString:
                lb $t1, ($t2)			#Valor del string Guardado
        	lb $t0, ($s3)			#Valor del separador
        	beq $t6,$s7,done		#Si terminó de reccorrer el array, finaliza
        	bne $t0, $t1, save		#Si no es el separador, se guarda en memoria
        	#lw $t4, newLine		#Trae el valor del salto de linea
        	#sw $t4,($t3)			#Si es el separador, se inserta un salto de linea
        	addi $t6, $t6, 1		#Se le suma 1 al contador
        	addi $t2, $t2, 1		#Se le suma una posición al string
        	addi $t3, $t3, 1		#Se le suma una posición al strin
        	j loopMemoryString
        	save:
        		sb $t1,($t3)		#Se guarda el char en el array
        		addi $t6, $t6, 1	#Se le suma 1 al contador
        		addi $t2, $t2, 1	#Se le suma una posición al string
        		addi $t3, $t3, 1	#Se le suma una posición al strin
        		j loopMemoryString
        
#Ordenamiento por bubbleSort
bubbleSort:   
    add $t0,$zero,$zero 	#  Se reinicia el contador

    loop:                
        beq $t0,$s7,done  	#  Se mira si ya se recorrió el string completo

        sub $t7,$s7,$t0 	#Se resta el valor máximo, menos el contador y se guarda en $t7
        addi $t7,$t7,-1 	#Y luego se le resta 1
        add $t1,$zero,$zero 	#Se inicializa el contador de el loop interno

        loopInterno:
        	sgt $t2, $t7, $t1 		#Miramos si ya recorrió todo le string.
        	beq $t2,$zero,continuar 	#Miramos si ya se recorrió todo el string (Menos uno y menos el $t0, que indica las pocisiones que ya están ordenadas)
            #Ahora cargamos los valores que vamos a comparar (I y I+1)
##############SUMAR LO QUE LLEVABA DEL SALTO AL MOMENTO DE ENCONTRAR EL SEPARADOR
 		add $t6,$s0,$t1 			#Acá está la dirección del vector y I
###########SUMAR LO QUE LLEVABA DEL SALTO AL MOMENTO DE ENCONTRAR EL SEPARADOR
		lb  $s1,0($t6) #Acá se lleva vector[i]
		####################################################################
		##Buscamos la siguiente frase para ser ordenada (Se guarda en $s6)##
		####################################################################
            	addi $s6, $t6, 1
		lb  $s2,0($s6) 			#Acá se lleva vector [i+1]
		##########################################
		##Validamos si la frase es mayor o menor##
		##########################################
		sgt $t2, $s1,$s2 			#Si vector[i] > vector[i+i] entonces arroja true, si no, arroja false
		beq $t2, $zero, false 		#Si es false entonces no se intercambia y se sigue con el siguiente número.
		########################################
		##Ordenamos las frases si es necesario##
		 ########################################
            	addi $sp,$sp,-4 		#Mueve cuatro posiciones para abajo el apilador
    		sw $ra, 0($sp) 			#Guarda la dirección de RA en el apilador
		jal swap 			#Se intercambia el valor.
		lw $ra, 0($sp)			 #Saca la posición anterior de RA
		addi $sp, $sp, 4 		#Mueve cuatro posición para desapilar
		
            	false:
            	addi $t1,$t1,1 			#Se le suma uno al contador interno
           	j loopInterno
	
        continuar:
        addi $t0,$t0,1 				#Se le suma uno al contador externo
        j loop
        

#Procedimiento para imprimir
print:
    # Salto de linea para que quede la solución bajo la pregunta
    	
    	addi $sp,$sp,-4 			#Mueve cuatro posiciones para abajo el apilador
    	sw $ra, 0($sp) 				#Guarda la dirección de RA en el apilador
	jal saltoLinea 				#Imprime un salto de linea
	lw $ra, 0($sp) 				#Saca la posición anterior de RA
	addi $sp, $sp, 4 			#Mueve cuatro posición para desapilar	
	#Ahora, para imprimir el string se crea un loop
    	add $t6,$zero,$zero 			# Se pone el valor del contador en 0

    loopPrint:
        beq $t6,$s7,done  			#Se mira si ya recorrió todo el string
        add $t1,$s0,$t6 			#Se trae la dirección del valor a imprimir
        lb $a0, 0($t1) 				# Se carga lo que se va a imprimir
        li $v0, 11      			# Se carga el código para imprimir por pantalla
        syscall         			# Se llama al sistema
    	addi $sp,$sp,-4 			#Mueve cuatro posiciones para abajo el apilador
    	sw $ra, 0($sp) 				#Guarda la dirección de RA en el apilador
	jal saltoLinea 				#Imprime un salto de linea
	lw $ra, 0($sp) 				#Saca la posición anterior de RA
	addi $sp, $sp, 4			#Mueve cuatro posición para desapilar	
        addi $t6,$t6,1 				#Se le suma uno al contador y vuelve al loop
        j loopPrint

saltoLinea:
        la $a0,newLine 				#Se ejecuta un salto de linea
   	li $v0,4				#Se imprime
   	syscall					#Se llama al sistema
	j done




swap: 
 	sb  $s2,0($t6) 			#Si es true, entonces se continua y se le mete el bit de $t6 a $s2
 	sb  $s1,0($s6)			#y se le mete el $t6+1 a $s1
 	j done

###INTENTO DE BUSCAR EL SEPARADOR####
#nextPhrase:
#	lb $t5, ($s3) 				#Cargamos el valor del separador en $t5
#	add $t3, $s1, $zero 			#Cargamos el valor del "Separador" encontrado
#	bne $s1, $t5, notSeparator 		#Se valida si son los mismos valores.
#	add $t4, $zero, $zero
#	findSeparator:
#		bne $t5, $t3, notSeparator 	#Validamos si no es separador
#		addi $t5,$t5,1 			#Sumamos uno a la dirección del separador
#		addi $t3, $t3, 1 		#Sumamos uno a la dirreción del "separador" encontrado
#		addi $t4, $t4, 1 		#Llevamos un contador
#		beq $t4, 2, thisIsSeparator 	#Si recorrió todo el addr y es, entonces lo encontró
#		j findSeparator			#Sigue en el bucle
#	thisIsSeparator:
#		addi $t1,$t1,1 			#Avanza dos posiciones
#		addi $s6, $t6, 2 		#Guarda la posición después del separador
#		j done
#	notSeparator:
#		addi $s6, $t6, 1		#Manda la siguiente posición sin contar el separador
#	j done  
	

#Acá se devuelve al metodo anterior.
done:
    jr $ra
    
#Finaliza la app
exit:
	
