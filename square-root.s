format:
  .ascii "Square root of %u is %u\n"
  .byte 0
  
.text

.global sq_root_compute_array
.global sq_root_compute_varargs

sq_root_compute_array:
  pushq %rbp
  movq %rsp, %rbp
  subq $32, %rsp
  
  movq $0, %r13               /* outerCounter = 0 */
  movq %rcx, %r15             /* move noElem to r15 */
  cmp %r15, %r13              /* if noElem == 0 */
  jz endSqRootArray
  movq %rdx, %r14             /* move array to r14 */
outerLoop:
  movl (%r14, %r13, 4), %esi  /* move value of array[0] to rsi */
  movq %rsi, %rcx
  pushq %r13
  pushq %r15
  pushq %r14
  call computeSquareRoot
  popq %r14
  popq %r15
  popq %r13
  inc %r13

  cmp %r15, %r13          /* if(outerCounter < noElem) */
  jl outerLoop
endSqRootArray:
  movq %rbp, %rsp
  popq %rbp
  ret
  
computeSquareRoot:
  pushq %rbp
  movq %rsp, %rbp
  subq $32, %rsp
  
  movq %rcx, %r12         /* store original value to r12 */
  movq %r12, %rsi         /* store value to rsi */
  movq $1, %rbx           /* oddno = 1 */
  movq $1, %rdi           /* counter = 1 */
  cmp $0, %r12            /* if value == 0 return 0 */
  jz computeSqZero
computeSqLoop:
  subl %ebx, %esi         /* value - oddno */
  cmpq %rsi, %rbx
  ja computeSqEnd         /* if rbx > rsi (oddno > value) */
  addq $2, %rbx           /* oddno += 2 */
  addq $1, %rdi           /* counter += 1 */
  jmp computeSqLoop
computeSqZero:
  subq $1, %rdi
computeSqEnd:
  leaq format(%rip), %rcx  /* set format as 1st param */
  movq %r12, %rdx          /* set original value as 2nd param */
  movq %rdi, %r8           /* set loop counter as 3rd param */
  call printf

  movq %rbp, %rsp
  popq %rbp
  ret
  
sq_root_compute_varargs:
  pushq %rbp
  movq %rsp, %rbp
  subq $32, %rsp
  
  cmp $0, %rcx     /* Check if 1st arg is 0 */
  jz sqRootVarEnd  /* If not zero, compute sqroot */
  pushq %rdx
  pushq %r8
  pushq %r9
  call computeSquareRoot
  popq %r9
  popq %r8
  popq %rdx
  
  cmp $0, %rdx    /* Check if 2nd arg is 0 */
  jz sqRootVarEnd
  movq %rdx, %rcx /* set as 1st param */
  pushq %r8
  pushq %r9
  call computeSquareRoot
  popq %r9
  popq %r8
  
  cmp $0, %r8    /* Check if 3rd arg is 0 */
  jz sqRootVarEnd
  movq %r8, %rcx 
  pushq %r9
  call computeSquareRoot
  popq %r9
  
  cmp $0, %r9   /* Check if 4th arg is 0 */
  jz sqRootVarEnd
  movq %r9, %rcx
  call computeSquareRoot
  
  movq %rbp, %rsi
  addq $48, %rsi  /* move stack pointer */
  movl (%rsi), %ecx
LoopUntilZero:
  cmp $0, %rcx
  jz sqRootVarEnd
  pushq %rsi
  call computeSquareRoot
  popq %rsi
  addq $8, %rsi
  movq (%rsi), %rcx
  jmp LoopUntilZero
  
  
sqRootVarEnd:
  movq %rbp, %rsp
  popq %rbp
  ret
  
.data
