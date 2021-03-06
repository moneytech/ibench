#define INSTR vrsqrt14pd
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
        # create SP 1.0
        vpcmpeqw xmm0, xmm0, xmm0       # all ones
        vpsllq xmm0, xmm0, 54           # logical left shift: 11111110..0 (54 = 64 - (11 - 1))
        vpsrlq xmm0, xmm0, 2            # logical right shift: 1 bit for sign; leading mantissa bit is zero
        vinsertf128 ymm0, ymm0, xmm0, 0x1
        vinsertf64x4 zmm0, zmm0, ymm0, 0x1

        vaddpd zmm1, zmm0, zmm0     # create 2.0
        vaddpd zmm2, zmm0, zmm1     # create 3.0
        vaddpd zmm4, zmm1, zmm1     # create 4.0
        vaddpd zmm4, zmm4, zmm4     # create 8.0
        vaddpd zmm4, zmm4, zmm4     # create 16.0
        vaddpd zmm4, zmm4, zmm4     # create 32.0
        vaddpd zmm4, zmm4, zmm4     # create 64.0
        vaddpd zmm4, zmm4, zmm4     # create 128.0
        vaddpd zmm4, zmm4, zmm4     # create 256.0
        vaddpd zmm4, zmm4, zmm4     # create 512.0
        vaddpd zmm4, zmm4, zmm4     # create 1024.0
        vdivpd zmm1, zmm4, zmm2     # create 341.3333
        vdivpd zmm2, zmm0, zmm1     # create 1/341.3333
        vaddpd zmm0, zmm1, zmm1     # create 2*341.3333
        vmovapd zmm1, zmm0
        vmovapd zmm2, zmm0
        vmovapd zmm3, zmm0
        vmovapd zmm4, zmm0
        vmovapd zmm5, zmm0
loop:
        inc       i
        INSTR     zmm10, zmm0
        INSTR     zmm11, zmm1
        INSTR     zmm12, zmm2
        cmp       i, N
        INSTR     zmm13, zmm3
        INSTR     zmm14, zmm4
        INSTR     zmm15, zmm5
        jl        loop
done:
        mov  rsp, rbp
        pop rbp
        ret
.size latency, .-latency
