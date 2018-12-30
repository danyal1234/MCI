	PRESERVE8
	AREA MyCode, CODE, READWRITE    ;specifies memory
	EXPORT asmmain                  ;declares a symbol that can be used by the linker to resolve symbol references in separate object and library files.
	EXTERN lptmrCounter				;get global var from main.c
	import my_print					;function defined in the main.c


LPTMR0_CSR EQU 0x40040000  	;CSR register address
LPTMR0_PSR EQU 0x40040004  	;PSR register address
LPTMR0_CMR EQU 0x40040008  	;CMR register address
LPTMR0_CNR EQU 0x4004000C  	;CNR register address
SIM_SCGC5  EQU 0x40048038   ; This enables the lptmr to enable interrupts
NVIC_Value EQU 0x00200000	
NVIC_Addr  EQU 0xe000e108	

asmmain

	LDR r0, =SIM_SCGC5  ; enable the lptmr ; loads address of internal clock
	MOV r1, #1			;r1 = 1
	LDR r2, [r0]		;loads value of internal clock into r2
	ORR r2, r2, r1 		;oring setting last bit to one enables the lptmr
	STR r2, [r0] 		;store r2 into r0
	
	;enable NVIC
	LDR r2, =NVIC_Value		;load address of NVIC_value
	LDR r1, =NVIC_Addr		;load address of NVIC
	STR r2, [r1]			;moving NVIC value(0x00200000) into NVIC address to enable IRQ 85
	
	LDR r0, =LPTMR0_CSR		;loading address of LPTMR0_CSR to clear
	MOV r1, #0x40 			;setting 6th bit to one-->initializing interrupts 
	STR r1, [r0]			
	
	
	ADD r0, #0x4 ; increasing the r0 with 4 byte  -- r0 has 0x40040000 + 4 byte == LPTMR0_CSR
	MOV r1, #0x5 ; prescale off and timer mode on
	STR r1, [r0]
	
	
	
	ADD r0, #0x4	;go to CMR address 
	MOV r1, #0x1338 ; setting timer to interept every 5 seconds - 0x1388 = 5000ms because clock is 1kHz 
	STR r1, [r0]	;storing that value into CMR address
	
	SUB r0, #0x8	;go back to CSR address 
	MOV r1, #0x1	;setting to 1 
	
	LDR r2, [r0]	;loads CSR value into r2
	ORR r2, r2, r1	;OR result into r2 
	
	STR r2, [r0]	;r0 = r2 value --> LPTMR is enabled.
	MOV r10, #0		;clear r10&r7  
	MOV r7, #0		
	
	LDR r5, =lptmrCounter 	
	
counter_loop
	B counter_loop
	BX lr

	END