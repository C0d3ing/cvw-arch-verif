///////////////////////////////////////////
//
// RISC-V Architectural Functional Coverage Covergroups
//
// Written: Corey Hickson chickson@hmc.edu 13 November 2024
// 
// Copyright (C) 2024 Harvey Mudd College, 10x Engineers, UET Lahore, Habib University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

`define COVER_ZICSRU
typedef RISCV_instruction #(ILEN, XLEN, FLEN, VLEN, NHART, RETIRE) ins_zicsru_t;

covergroup ucsr_cg with function sample(ins_zicsru_t ins);
    option.per_instance = 0; 
    // "ZicsrU ucsr"

    // building blocks for the main coverpoints

    nonzerord: coverpoint ins.current.insn[11:7] {
        type_option.weight = 0;
        bins nonzero = { [1:$] }; // rd != 0
    }
    csrr: coverpoint ins.current.insn  {
        wildcard bins csrr = {32'b????????????_00000_010_?????_1110011};
    }
    csrrw: coverpoint ins.current.insn {
        wildcard bins csrrw = {32'b????????????_?????_001_?????_1110011}; 
    }
    csr: coverpoint ins.current.insn[31:20]  {
    // automtically gives all 4096 bins
    }
    priv_mode_u: coverpoint ins.current.mode {
        bins U_mode = {2'b00};
    }
    rs1_ones: coverpoint ins.current.rs1_val {
        bins ones = {'1};
    }
    rs1_corners: coverpoint ins.current.rs1_val {
        bins zero = {0};
        bins ones = {'1};
    }
    csrop: coverpoint ins.current.insn[14:12] iff (ins.current.insn[6:0] == 7'b1110011) {
        bins csrrs = {3'b010};
        bins csrrc = {3'b011};
    }
    
    // main coverpoints
    cp_csrr:         cross csrr,  csr, priv_mode_u, nonzerord;
    cp_csrw_corners: cross csrrw, csr, priv_mode_u, rs1_corners;
    cp_csrcs:        cross csrop, csr, priv_mode_u, rs1_ones;
endgroup

covergroup mstatus_u_cg with function sample(ins_zicsru_t ins);
    option.per_instance = 0; 
    // "ZicsrU mstatus UBE"

    // building blocks for the main coverpoints
    cp_sw: coverpoint ins.current.insn {
        wildcard bins sw = {32'b????????????_?????_010_?????_0100011}; 
    }
    cp_sh: coverpoint ins.current.insn {
        wildcard bins sh = {32'b????????????_?????_001_?????_0100011}; 
    }
    cp_sb: coverpoint ins.current.insn {
        wildcard bins sb = {32'b????????????_?????_000_?????_0100011}; 
    }
    cp_lw: coverpoint ins.current.insn {
        wildcard bins lw = {32'b????????????_?????_010_?????_0000011}; 
    }
    cp_lh: coverpoint ins.current.insn {
        wildcard bins lh = {32'b????????????_?????_001_?????_0000011}; 
    }
    cp_lhu: coverpoint ins.current.insn {
        wildcard bins lhu = {32'b????????????_?????_101_?????_0000011}; 
    }
    cp_lb: coverpoint ins.current.insn {
        wildcard bins lb = {32'b????????????_?????_000_?????_0000011}; 
    }
    cp_lbu: coverpoint ins.current.insn {
        wildcard bins lbu = {32'b????????????_?????_100_?????_0000011}; 
    }
    cp_byteoffset: coverpoint ins.current.imm[2:0] iff (ins.current.rs1_val[2:0] == 3'b000) {
        // all byte offsets
    }
    cp_halfoffset: coverpoint ins.current.imm[2:1] iff (ins.current.rs1_val[2:0] == 3'b000 & ins.current.imm[0] == 1'b0)  {
        // all halfword offsets
    }    
    cp_wordoffset: coverpoint ins.current.imm[2] iff (ins.current.rs1_val[2:0] == 3'b000 & ins.current.imm[1:0] == 2'b00)  {
        // all word offsets
    }    
    priv_mode_u: coverpoint ins.current.mode {
       bins U_mode = {2'b00};
    }
    mstatus_ube: coverpoint ins.current.csr[12'h300][6] { // ube is mstatus[6]
    }
    mstatus_mprv: coverpoint ins.current.csr[12'h300][17] { // mprv is mstatus[17]
    }
    mstatus_mpp: coverpoint ins.current.csr[12'h300][12:11] { // mprv is mstatus[12:11]
        bins U_Mode = {2'b00};
        bins M_Mode = {2'b11};
    }
    `ifdef XLEN64
        mstatus_mbe: coverpoint ins.current.csr[12'h300][37] { // mbe is mstatus[37] in RV64
    }
    `else
        mstatus_mbe: coverpoint ins.current.csr[12'h310][5] { // mbe is mstatush[5] in RV32
    }
    `endif
    
    // main coverpoints
    cp_mstatus_ube_endianness_sw:  cross priv_mode_u, mstatus_ube, cp_sw,  cp_wordoffset;
    cp_mstatus_ube_endianness_sh:  cross priv_mode_u, mstatus_ube, cp_sh,  cp_halfoffset;
    cp_mstatus_ube_endianness_sb:  cross priv_mode_u, mstatus_ube, cp_sb,  cp_byteoffset;
    cp_mstatus_ube_endianness_lw:  cross priv_mode_u, mstatus_ube, cp_lw,  cp_wordoffset;
    cp_mstatus_ube_endianness_lh:  cross priv_mode_u, mstatus_ube, cp_lh,  cp_halfoffset;
    cp_mstatus_ube_endianness_lb:  cross priv_mode_u, mstatus_ube, cp_lb,  cp_byteoffset;
    cp_mstatus_ube_endianness_lhu: cross priv_mode_u, mstatus_ube, cp_lhu, cp_halfoffset;
    cp_mstatus_ube_endianness_lbu: cross priv_mode_u, mstatus_ube, cp_lbu, cp_byteoffset;
    cp_mstatus_mprv_ube_endianness_sw:  cross priv_mode_u, mstatus_ube, cp_sw,  cp_wordoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
    cp_mstatus_mprv_ube_endianness_sh:  cross priv_mode_u, mstatus_ube, cp_sh,  cp_halfoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
    cp_mstatus_mprv_ube_endianness_sb:  cross priv_mode_u, mstatus_ube, cp_sb,  cp_byteoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
    cp_mstatus_mprv_ube_endianness_lw:  cross priv_mode_u, mstatus_ube, cp_lw,  cp_wordoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
    cp_mstatus_mprv_ube_endianness_lh:  cross priv_mode_u, mstatus_ube, cp_lh,  cp_halfoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
    cp_mstatus_mprv_ube_endianness_lb:  cross priv_mode_u, mstatus_ube, cp_lb,  cp_byteoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
    cp_mstatus_mprv_ube_endianness_lhu: cross priv_mode_u, mstatus_ube, cp_lhu, cp_halfoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
    cp_mstatus_mprv_ube_endianness_lbu: cross priv_mode_u, mstatus_ube, cp_lbu, cp_byteoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;

    `ifdef XLEN64

        cp_sd: coverpoint ins.current.insn {
            wildcard bins sd = {32'b????????????_?????_011_?????_0100011}; 
        }
        cp_ld: coverpoint ins.current.insn {
            wildcard bins ld = {32'b????????????_?????_001_?????_0000011}; 
        }
        cp_lwu: coverpoint ins.current.insn {
            wildcard bins lwu = {32'b????????????_?????_110_?????_0000011}; 
        }
        cp_doubleoffset: coverpoint ins.current.imm[2:0] iff (ins.current.rs1_val[2:0] == 3'b000)  {
            bins zero = {3'b000};
        }
        cp_mstatus_ube_endianness_sd:  cross priv_mode_u, mstatus_ube, cp_sd, cp_doubleoffset;
        cp_mstatus_ube_endianness_ld:  cross priv_mode_u, mstatus_ube, cp_ld, cp_doubleoffset;
        cp_mstatus_ube_endianness_lwu: cross priv_mode_u, mstatus_ube, cp_lwu, cp_wordoffset;
        cp_mstatus_mpr_ube_endianness_sd:  cross priv_mode_u, mstatus_ube, cp_sd, cp_doubleoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
        cp_mstatus_mpr_ube_endianness_ld:  cross priv_mode_u, mstatus_ube, cp_ld, cp_doubleoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
        cp_mstatus_mpr_ube_endianness_lwu: cross priv_mode_u, mstatus_ube, cp_lwu, cp_wordoffset, mstatus_mprv, mstatus_mbe, mstatus_mpp;
    `endif
endgroup

covergroup uprivinst_cg with function sample(ins_zicsru_t ins);
    option.per_instance = 0; 
    // "ZicsrU uprivinst"

    // building blocks for the main coverpoints
    privinstrs: coverpoint ins.current.insn  {
        bins ecall  = {32'h00000073};
        bins ebreak = {32'h00100073};
    }
    mret: coverpoint ins.current.insn  {
        bins mret   = {32'h30200073};
    }
    sret: coverpoint ins.current.insn  {
        bins sret   = {32'h10200073};
    }
    priv_mode_u: coverpoint ins.current.mode {
       bins U_mode = {2'b00};
    }
    old_priv_mode_u: coverpoint ins.prev.mode {
       bins U_mode = {2'b00};
    }
    // main coverpoints
    cp_uprivinst:  cross privinstrs, priv_mode_u;
    cp_mret:       cross mret, old_priv_mode_u; // should trap 
    cp_sret:       cross sret, old_priv_mode_u; // should trap 
endgroup

function void zicsru_sample(int hart, int issue);
    ins_zicsru_t ins;

    ins = new(hart, issue, traceDataQ); 
    ins.add_rd(0);
    ins.add_rs1(2);
    ins.add_csr(1);
    
    ucsr_cg.sample(ins);
    mstatus_u_cg.sample(ins);
    uprivinst_cg.sample(ins);
    
endfunction
