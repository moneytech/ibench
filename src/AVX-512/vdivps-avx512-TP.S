#define INSTR vdivps
#define NINST 6
#define N edi
#define i r8d


.intel_syntax noprefix
.globl ninst
.data
ninst:
.long NINST
.text
.globl latency
.type latency, @function
.align 32
latency:
        push      rbp
        mov       rbp, rsp
        xor       i, i
        test      N, N
        jle       done
        # create SSE SP 1.0
        vpcmpeqw xmm0, xmm0, xmm0       # all ones
        vpslld xmm0, xmm0, 25           # logical left shift: 11111110..0 (25 = 32 - (8 - 1))
        vpsrld xmm0, xmm0, 2            # logical right shift: 1 bit for sign; leading mantissa bit is zero
        # expand from SSE to AVX
        vinsertf128 ymm0, ymm0, xmm0, 0x1
        # expand from AVX to AVX-512
        vinsertf64x4 zmm0, zmm0, ymm0, 0x1

        vaddps zmm1, zmm0, zmm0     # create 2.0
        vaddps zmm2, zmm0, zmm1     # create 3.0
        vaddps zmm4, zmm1, zmm1     # create 4.0
        vaddps zmm4, zmm4, zmm4     # create 8.0
        vaddps zmm4, zmm4, zmm4     # create 16.0
        vaddps zmm4, zmm4, zmm4     # create 32.0
        vaddps zmm4, zmm4, zmm4     # create 64.0
        vaddps zmm4, zmm4, zmm4     # create 128.0
        vaddps zmm4, zmm4, zmm4     # create 256.0
        vaddps zmm4, zmm4, zmm4     # create 512.0
        vaddps zmm4, zmm4, zmm4     # create 1024.0
        vdivps zmm1, zmm4, zmm2     # create 341.3333
        vdivps zmm2, zmm0, zmm1     # create 1/341.3333
        vaddps zmm0, zmm1, zmm1     # create 2*341.3333
loop:
        inc       i
        INSTR     zmm3, zmm0, zmm1
        INSTR     zmm4, zmm1, zmm2
        INSTR     zmm5, zmm0, zmm2
        cmp       i, N
        INSTR     zmm6, zmm2, zmm0
        INSTR     zmm7, zmm1, zmm2
        INSTR     zmm8, zmm2, zmm1
        jl        loop
done:
        mov  rsp, rbp
        pop rbp
        ret
.size latency, .-latency
