///////////////////////////////////////////
//
// RISC-V Architectural Functional Coverage Covergroups
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

`define COVER_RV32VM
typedef RISCV_instruction #(ILEN, XLEN, FLEN, VLEN, NHART, RETIRE) ins_rv32vm_t;

covergroup satp_cg with function sample(ins_rv32vm_t ins);
    option.per_instance = 0; 
    mode_supported: coverpoint ins.current.csr[12'h180][31] { //sat.2
        bins sv32   = {1'b1};
        bins bare   = {1'b0}; //bare.1
    }

    satp_asid_PPN: coverpoint ins.current.csr[12'h180][30:0] {
        bins all_zero = {31'd0};
        bins not_zero = {[1:$]};
    }

    asid_Length: coverpoint ins.current.csr[12'h180][30:22] { //sat.4
        bins values = {9'h001, 9'h002, 9'h004, 9'h008, 9'h010, 9'h020, 9'h040, 9'h080, 9'h100};
    }

    bare_mode: cross mode_supported, satp_asid_PPN { //sat.3
        ignore_bins ig1 = binsof(mode_supported.sv32);
    }

    tvm_mstatus: coverpoint ins.current.csr[12'h300][20]{
        bins zero = {0};
    }
    priv_mode: coverpoint ins.current.mode{
        bins S_mode = {2'b01};
        bins U_mode = {2'b00};
        bins M_mode = {2'b11};
    }
    Mcause: coverpoint ins.current.csr[12'h342]{
        bins illegal_ins  = {32'd2};
        bins no_exception = {32'd0};
    }
    ins: coverpoint ins.current.insn {
        wildcard bins csrrs = {32'b000110000000_?????_010_?????_1110011};
        wildcard bins csrrw = {32'b000110000000_?????_001_?????_1110011};
        wildcard bins csrrc = {32'b000110000000_?????_011_?????_1110011};
    }

    access_u: cross priv_mode, ins, Mcause, tvm_mstatus { //sat.1
        ignore_bins ig1 = binsof(priv_mode.S_mode);
        ignore_bins ig2 = binsof(priv_mode.M_mode);
        ignore_bins ig3 = binsof(Mcause.no_exception);
    }
    access_m_s: cross priv_mode, ins, Mcause, tvm_mstatus { //sat.1
        ignore_bins ig1 = binsof(priv_mode.U_mode);
        ignore_bins ig2 = binsof(Mcause.illegal_ins);
    }
endgroup

covergroup PA_VA_cg with function sample(ins_rv32vm_t ins); //checking that all bits of PA and VA are live
    option.per_instance = 0; 
    VA_i: coverpoint ins.current.VAdrI { 
        bins all_zeros = {32'd0};
        bins all_ones  = {32'hFFFFFFFF};
    }
    VA_d: coverpoint ins.current.VAdrD { 
        bins all_zeros = {32'd0};
        bins all_ones  = {32'hFFFFFFFF};
    }

    PA_i: coverpoint ins.current.PAI {
        bins all_zeros = {34'd0};
        bins all_ones  = {34'h3_FFFFFFFF};
    }
    PA_d: coverpoint ins.current.PAD {
        bins all_zeros = {34'd0};
        bins all_ones  = {34'h3_FFFFFFFF};
    }

    mode_supported: coverpoint ins.current.csr[12'h180][31] {
        bins sv32   = {1'b1};
        bins bare   = {1'b0};
    }

    VA_i_sv32: cross mode_supported, VA_i;
    VA_d_sv32: cross mode_supported, VA_d;
    PA_i_sv32: cross mode_supported, PA_i;
    PA_d_sv32: cross mode_supported, PA_d;
endgroup

covergroup sfence_cg with function sample(ins_rv32vm_t ins); //sf.1
    option.per_instance = 0; 
    ins: coverpoint ins.current.insn { 
        wildcard bins sfence = {32'b0001001_?????_?????_000_00000_1110011};
    }
endgroup

covergroup mstatus_mprv_cg with function sample(ins_rv32vm_t ins);
    option.per_instance = 0; 
    tvm_mstatus: coverpoint ins.current.csr[12'h300][20] {
        bins set = {1};
    }
    priv_mode: coverpoint ins.current.mode {
        bins S_mode = {2'b01};
        bins M_mode = {2'b11};
    }
    Mcause: coverpoint ins.current.csr[12'h342] {
        bins illegal_ins = {32'd2};
    }
    ins: coverpoint ins.current.insn {
        wildcard bins csrrs_stap = {32'b000110000000_?????_010_?????_1110011};
        wildcard bins csrrw_stap = {32'b000110000000_?????_001_?????_1110011};
        wildcard bins csrrc_stap = {32'b000110000000_?????_011_?????_1110011};
        wildcard bins sfence = {32'b0001001_?????_?????_000_00000_1110011};
    }

    tvm_exception_s: cross tvm_mstatus, priv_mode, Mcause, ins { //ms.1
        ignore_bins ig1 = binsof(priv_mode.M_mode);
    }

    mprv_mstatus: coverpoint ins.current.csr[12'h300][17]{
        bins set = {1};
    }
    mpp_mstatus: coverpoint ins.current.csr[12'h300][12:11] {
        bins U_mode = {2'b00};
        bins S_mode = {2'b01};
    }
    read_acc: coverpoint ins.current.ReadAccess {
        bins set = {1};
    }
    write_acc: coverpoint ins.current.WriteAccess {
        bins set = {1};
    }
    exec_acc: coverpoint ins.current.ExecuteAccess {
        bins set = {1};
    }
    satp_mode: coverpoint  ins.current.csr[12'h180][31] {
        bins sv32   = {1'b1};
        bins bare   = {1'b0};
    }

    mprv_load: cross mprv_mstatus, mpp_mstatus, read_acc, priv_mode, satp_mode { //ms.2
        ignore_bins ig1 = binsof(priv_mode.S_mode);
    }
    mprv_store: cross mprv_mstatus, mpp_mstatus, write_acc, priv_mode, satp_mode { //ms.2
        ignore_bins ig1 = binsof(priv_mode.S_mode);
    }
    mprv_ins: cross mprv_mstatus, mpp_mstatus, exec_acc , priv_mode, satp_mode { //ms.2
        ignore_bins ig1 = binsof(priv_mode.S_mode);
    }
endgroup

covergroup vm_permissions_cg with function sample(ins_rv32vm_t ins);
    option.per_instance = 0; 
    //pte permission for leaf PTEs
    PTE_i_inv: coverpoint ins.current.PTE_i[7:0] { //pte.2
        wildcard bins leaflvl_u = {8'b???11??0};
        wildcard bins leaflvl_s = {8'b???01??0};
    }
    PTE_d_inv: coverpoint ins.current.PTE_d[7:0] { //pte.2
        wildcard bins leaflvl_u_r = {8'b???1??10};
        wildcard bins leaflvl_u_w = {8'b???1?110};
        wildcard bins leaflvl_s_r = {8'b???0??10};
        wildcard bins leaflvl_s_w = {8'b???0?110};
    }

    PTE_i_res_rwx: coverpoint ins.current.PTE_i[7:0] { //pte.3
        wildcard bins leaflvl_exec_u = {8'b???11101};
        wildcard bins leaflvl_noexec_u = {8'b???10101};
        wildcard bins leaflvl_exec_s = {8'b???01101};
        wildcard bins leaflvl_noexec_s = {8'b???00101};
    }
    PTE_d_res_rwx: coverpoint ins.current.PTE_d[7:0] { //pte.3
        wildcard bins leaflvl_exec_u = {8'b???11101};
        wildcard bins leaflvl_noexec_u = {8'b???10101};
        wildcard bins leaflvl_exec_s = {8'b???01101};
        wildcard bins leaflvl_noexec_s = {8'b???00101};
    }

    PTE_nonleaf_lvl0_i: coverpoint ins.current.PTE_i[7:0] { //pte.4
        wildcard bins lvl0_s = {8'b???00001};
        wildcard bins lvl0_u = {8'b???10001};
    }
    PTE_nonleaf_lvl0_d: coverpoint ins.current.PTE_d[7:0] { //pte.4
        wildcard bins lvl0_s = {8'b???00001};
        wildcard bins lvl0_u = {8'b???10001};
    }

    PTE_x_spage_i: coverpoint ins.current.PTE_i[7:0] { //pte.5 & 6
        wildcard bins leaflvl_x_0 = {8'b???00??1};
        wildcard bins leaflvl_x_1 = {8'b???01??1};
    }
    PTE_rw_spage_d: coverpoint ins.current.PTE_d[7:0] { //pte.5 & 6
        wildcard bins leaflvl_w_0 = {8'b???0?0?1};
        wildcard bins leaflvl_w_1 = {8'b???0?111};
        wildcard bins leaflvl_r_0 = {8'b???0??01};
        wildcard bins leaflvl_r_1 = {8'b???0??11};
    }

    PTE_spage_i: coverpoint ins.current.PTE_i[7:0] { //pte.7
        wildcard bins leaflvl_s = {8'b???01111};
    }
    PTE_spage_d: coverpoint ins.current.PTE_d[7:0] { //pte.7
        wildcard bins leaflvl_s = {8'b???01111};
    }

    PTE_upage_i: coverpoint ins.current.PTE_i[7:0] { //pte.8 & 9
        wildcard bins leaflvl_u = {8'b???11111};
    }
    PTE_upage_d: coverpoint ins.current.PTE_d[7:0] { //pte.8 & 9
        wildcard bins leaflvl_u = {8'b???11111};
    }

    PTE_x_upage_i: coverpoint ins.current.PTE_i[7:0] { //pte.10
        wildcard bins leaflvl_x_0 = {8'b???10??1};
        wildcard bins leaflvl_x_1 = {8'b???11??1};
    }
    PTE_rw_upage_d: coverpoint ins.current.PTE_d[7:0] { //pte.10
        wildcard bins leaflvl_w_0 = {8'b???1?0?1};
        wildcard bins leaflvl_w_1 = {8'b???1?111};
        wildcard bins leaflvl_r_0 = {8'b???1??01};
        wildcard bins leaflvl_r_1 = {8'b???1??11};
    }

    PTE_XnoRW_d: coverpoint ins.current.PTE_d[7:0] { //pte.11 & 12
        wildcard bins leaflvl_u = {8'b???11001};
        wildcard bins leaflvl_s = {8'b???01001};
    }

    PTE_Abit_unset_i: coverpoint ins.current.PTE_i[7:0] { //pte.14
        wildcard bins leaflvl_u = {8'b?0?11111};
        wildcard bins leaflvl_s = {8'b?0?01111};
    }
    PTE_Abit_unset_d: coverpoint ins.current.PTE_d[7:0] { //pte.14
        wildcard bins leaflvl_u = {8'b?0?11111};
        wildcard bins leaflvl_s = {8'b?0?01111};
    }

    PTE_Dbit_set_W_d: coverpoint ins.current.PTE_d[7:0] { //pte.15
        wildcard bins leaflvl_u = {8'b01?1?111};
        wildcard bins leaflvl_s = {8'b01?0?111};
    }

    PTE_RWX_i: coverpoint ins.current.PTE_i[7:0] { //pte.16
        wildcard bins leaflvl_u = {8'b???11111};
        wildcard bins leaflvl_s = {8'b???01111};
    }
    PTE_RWX_d: coverpoint ins.current.PTE_d[7:0] { //pte.16
        wildcard bins leaflvl_u = {8'b???11111};
        wildcard bins leaflvl_s = {8'b???01111};
    }

    //Pagetype && misaligned PPN for I&DTLB to ensure that leaf pte is found at all levels (through crosses of PTE and PageType)

    PageType_i: coverpoint ins.current.PageType_i {
        bins mega = {2'b01};
        bins kilo = {2'd0};
    }

    PageType_d: coverpoint ins.current.PageType_d {
        bins mega = {2'b01};
        bins kilo = {2'd0};
    }

    misaligned_PPN_i: coverpoint ins.current.PPN_i[9:0] {
        bins mega_not_zero = {[1:$]};
    }
    misaligned_PPN_d: coverpoint ins.current.PPN_d[9:0] {
        bins mega_not_zero = {[1:$]};
    }

    //satp.mode for coverage of both sv39 and sv48
    mode: coverpoint  ins.current.csr[12'h180][31] {
        bins sv32   = {1'b1};
    }

    //For crosses with Read, write and execute accesses and their corresponding faults
    exec_acc: coverpoint ins.current.ExecuteAccess {
        bins set = {1};
    }
    read_acc: coverpoint ins.current.ReadAccess {
        bins set = {1};
    }
    write_acc: coverpoint ins.current.WriteAccess{
        bins set = {1};
    }
    Mcause: coverpoint  ins.current.csr[12'h342] {
        bins load_page_fault = {32'd13};
        bins ins_page_fault  = {32'd12};
        bins store_amo_page_fault = {32'd15};
    }
        Nopagefault: coverpoint  ins.current.csr[12'h143]{
        bins no_fault  = {32'd0};
    }
    priv_mode: coverpoint ins.current.mode{
        bins S_mode = {2'b01};
        bins U_mode = {2'b00};
    }
    sum_sstatus: coverpoint ins.current.csr[12'h100][18]{
        bins notset = {0};
        bins set = {1};
    }
    mxr_sstatus: coverpoint ins.current.csr[12'h100][19] {
        bins notset = {0};
        bins set = {1};
    }

    PTE_inv_exec_s_i: cross PTE_i_inv, PageType_i, mode, Mcause, exec_acc  { //pte.2
        ignore_bins ig1 = binsof(PTE_i_inv.leaflvl_u);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(Mcause.store_amo_page_fault);
    }
    PTE_inv_exec_u_i: cross PTE_i_inv, PageType_i, mode, Mcause, exec_acc  { //pte.2
        ignore_bins ig1 = binsof(PTE_i_inv.leaflvl_s);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(Mcause.store_amo_page_fault);
    }

    PTE_inv_read_s_d: cross PTE_d_inv, PageType_d, mode, Mcause, read_acc { //pte.2
        ignore_bins ig1 = binsof(PTE_d_inv.leaflvl_u_r);
        ignore_bins ig2 = binsof(PTE_d_inv.leaflvl_u_w);
        ignore_bins ig3 = binsof(PTE_d_inv.leaflvl_s_w);
        ignore_bins ig4 = binsof(Mcause.ins_page_fault);
        ignore_bins ig5 = binsof(Mcause.store_amo_page_fault);
    }
    PTE_inv_read_u_d: cross PTE_d_inv, PageType_d, mode, Mcause, read_acc  { //pte.2
        ignore_bins ig1 = binsof(PTE_d_inv.leaflvl_s_r);
        ignore_bins ig2 = binsof(PTE_d_inv.leaflvl_s_w);
        ignore_bins ig3 = binsof(PTE_d_inv.leaflvl_u_w);
        ignore_bins ig4 = binsof(Mcause.ins_page_fault);
        ignore_bins ig5 = binsof(Mcause.store_amo_page_fault);
    }

    PTE_inv_write_s_d: cross PTE_d_inv, PageType_d, mode, Mcause, write_acc { //pte.2
        ignore_bins ig1 = binsof(PTE_d_inv.leaflvl_u_r);
        ignore_bins ig2 = binsof(PTE_d_inv.leaflvl_u_w);
        ignore_bins ig3 = binsof(PTE_d_inv.leaflvl_s_r);
        ignore_bins ig4 = binsof(Mcause.ins_page_fault);
        ignore_bins ig5 = binsof(Mcause.load_page_fault);
    }
    PTE_inv_write_u_d: cross PTE_d_inv, PageType_d, mode, Mcause, write_acc { //pte.2
        ignore_bins ig1 = binsof(PTE_d_inv.leaflvl_s_r);
        ignore_bins ig2 = binsof(PTE_d_inv.leaflvl_s_w);
        ignore_bins ig3 = binsof(PTE_d_inv.leaflvl_u_r);
        ignore_bins ig4 = binsof(Mcause.ins_page_fault);
        ignore_bins ig5 = binsof(Mcause.load_page_fault);
    }

    PTE_res_rwx_s_i_exec: cross PTE_i_res_rwx, PageType_i, mode, Mcause, exec_acc  { //pte.3
        ignore_bins ig1 = binsof(PTE_i_res_rwx.leaflvl_exec_u);
        ignore_bins ig2 = binsof(PTE_i_res_rwx.leaflvl_noexec_u);
        ignore_bins ig3 = binsof(Mcause.load_page_fault);
        ignore_bins ig4 = binsof(Mcause.store_amo_page_fault);
    }
    PTE_res_rwx_u_i_exec: cross PTE_i_res_rwx, PageType_i, mode, Mcause, exec_acc  { //pte.3
        ignore_bins ig1 = binsof(PTE_i_res_rwx.leaflvl_exec_s);
        ignore_bins ig2 = binsof(PTE_i_res_rwx.leaflvl_noexec_s);
        ignore_bins ig3 = binsof(Mcause.load_page_fault);
        ignore_bins ig4 = binsof(Mcause.store_amo_page_fault);
    }

    PTE_res_rwx_s_d_read: cross PTE_d_res_rwx, PageType_d, mode, Mcause, read_acc  { //pte.3
        ignore_bins ig1 = binsof(PTE_d_res_rwx.leaflvl_exec_u);
        ignore_bins ig2 = binsof(PTE_d_res_rwx.leaflvl_noexec_u);
        ignore_bins ig3 = binsof(Mcause.ins_page_fault);
        ignore_bins ig4 = binsof(Mcause.store_amo_page_fault);
    }
    PTE_res_rwx_u_d_read: cross PTE_d_res_rwx, PageType_d, mode, Mcause, read_acc  { //pte.3
        ignore_bins ig1 = binsof(PTE_d_res_rwx.leaflvl_exec_s);
        ignore_bins ig2 = binsof(PTE_d_res_rwx.leaflvl_noexec_s);
        ignore_bins ig3 = binsof(Mcause.ins_page_fault);
        ignore_bins ig4 = binsof(Mcause.store_amo_page_fault);
    }

    PTE_res_rwx_s_d_write: cross PTE_d_res_rwx, PageType_d, mode, Mcause, write_acc  { //pte.3
        ignore_bins ig1 = binsof(PTE_d_res_rwx.leaflvl_exec_u);
        ignore_bins ig2 = binsof(PTE_d_res_rwx.leaflvl_noexec_u);
        ignore_bins ig3 = binsof(Mcause.ins_page_fault);
        ignore_bins ig4 = binsof(Mcause.load_page_fault);
    }
    PTE_res_rwx_u_d_write: cross PTE_d_res_rwx, PageType_d, mode, Mcause, write_acc  { //pte.3
        ignore_bins ig1 = binsof(PTE_d_res_rwx.leaflvl_exec_s);
        ignore_bins ig2 = binsof(PTE_d_res_rwx.leaflvl_noexec_s);
        ignore_bins ig3 = binsof(Mcause.ins_page_fault);
        ignore_bins ig4 = binsof(Mcause.load_page_fault);
    }

    PTE_nonleaf_lvl0_s_i_exec: cross PTE_nonleaf_lvl0_i, PageType_i, mode, Mcause, exec_acc  { //pte.4
        ignore_bins ig1 = binsof(PTE_nonleaf_lvl0_i.lvl0_u);
        ignore_bins ig2 = binsof(PTE_nonleaf_lvl0_i.lvl0_s) && binsof(PageType_i.mega); 
        ignore_bins ig3 = binsof(Mcause.load_page_fault);
        ignore_bins ig4 = binsof(Mcause.store_amo_page_fault);       
    }

    PTE_nonleaf_lvl0_u_i_exec: cross PTE_nonleaf_lvl0_i, PageType_i, mode, Mcause, exec_acc  { //pte.4
        ignore_bins ig1 = binsof(PTE_nonleaf_lvl0_i.lvl0_s);
        ignore_bins ig2 = binsof(PTE_nonleaf_lvl0_i.lvl0_u) && binsof(PageType_i.mega);
        ignore_bins ig3 = binsof(Mcause.load_page_fault);
        ignore_bins ig4 = binsof(Mcause.store_amo_page_fault);        
    }

    PTE_nonleaf_lvl0_s_d_read: cross PTE_nonleaf_lvl0_d, PageType_d, mode, Mcause, read_acc { //pte.4
        ignore_bins ig1 = binsof(PTE_nonleaf_lvl0_d.lvl0_u);
        ignore_bins ig2 = binsof(PTE_nonleaf_lvl0_d.lvl0_s) && binsof(PageType_d.mega); 
        ignore_bins ig3 = binsof(Mcause.ins_page_fault);
        ignore_bins ig4 = binsof(Mcause.store_amo_page_fault);       
    }

    PTE_nonleaf_lvl0_u_d_read: cross PTE_nonleaf_lvl0_d, PageType_d, mode, Mcause, read_acc { //pte.4
        ignore_bins ig1 = binsof(PTE_nonleaf_lvl0_d.lvl0_s);
        ignore_bins ig2 = binsof(PTE_nonleaf_lvl0_d.lvl0_u) && binsof(PageType_d.mega);
        ignore_bins ig3 = binsof(Mcause.ins_page_fault);
        ignore_bins ig4 = binsof(Mcause.store_amo_page_fault);        
    }

    PTE_nonleaf_lvl0_s_d_write: cross PTE_nonleaf_lvl0_d, PageType_d, mode, Mcause, write_acc { //pte.4
        ignore_bins ig1 = binsof(PTE_nonleaf_lvl0_d.lvl0_u);
        ignore_bins ig2 = binsof(PTE_nonleaf_lvl0_d.lvl0_s) && binsof(PageType_d.mega);  
        ignore_bins ig3 = binsof(Mcause.ins_page_fault);
        ignore_bins ig4 = binsof(Mcause.load_page_fault);      
    }

    PTE_nonleaf_lvl0_u_d_write: cross PTE_nonleaf_lvl0_d, PageType_d, mode, Mcause, write_acc { //pte.4
        ignore_bins ig1 = binsof(PTE_nonleaf_lvl0_d.lvl0_s);
        ignore_bins ig2 = binsof(PTE_nonleaf_lvl0_d.lvl0_u) && binsof(PageType_d.mega); 
        ignore_bins ig3 = binsof(Mcause.ins_page_fault);
        ignore_bins ig4 = binsof(Mcause.load_page_fault);       
    }

    spage_exec_s_i: cross PTE_x_spage_i, PageType_i, mode, exec_acc, Nopagefault, priv_mode, sum_sstatus { //pte.5 & 6 
        ignore_bins ig1 = binsof(PTE_x_spage_i.leaflvl_x_0);
        ignore_bins ig2 = binsof(priv_mode.U_mode);
    }
    spage_noexec_s_i: cross PTE_x_spage_i, PageType_i, mode, Mcause, exec_acc, priv_mode, sum_sstatus { //pte.5 & 6
        ignore_bins ig1 = binsof(PTE_x_spage_i.leaflvl_x_1);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig4 = binsof(priv_mode.U_mode);
    }

    spage_read_s_d: cross PTE_rw_spage_d, PageType_d, mode, Nopagefault, read_acc, priv_mode, sum_sstatus { //pte.5 & 6
        ignore_bins ig1 = binsof(priv_mode.U_mode);
        ignore_bins ig2 = binsof(PTE_rw_spage_d.leaflvl_r_0);
        ignore_bins ig3 = binsof(PTE_rw_spage_d.leaflvl_w_0);
        ignore_bins ig4 = binsof(PTE_rw_spage_d.leaflvl_w_1);
    }
    spage_noread_s_d: cross PTE_rw_spage_d, PageType_d, mode, Mcause, read_acc, priv_mode, sum_sstatus { //pte.5 & 6
        ignore_bins ig1 = binsof(priv_mode.U_mode);
        ignore_bins ig2 = binsof(PTE_rw_spage_d.leaflvl_r_1);
        ignore_bins ig3 = binsof(PTE_rw_spage_d.leaflvl_w_0);
        ignore_bins ig4 = binsof(PTE_rw_spage_d.leaflvl_w_1);
        ignore_bins ig5 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig6 = binsof(Mcause.ins_page_fault);
    }

    spage_write_s_d: cross PTE_rw_spage_d, PageType_d, mode, Nopagefault, write_acc, priv_mode, sum_sstatus { //pte.5 & 6
        ignore_bins ig1 = binsof(priv_mode.U_mode);
        ignore_bins ig2 = binsof(PTE_rw_spage_d.leaflvl_r_0);
        ignore_bins ig3 = binsof(PTE_rw_spage_d.leaflvl_w_0);
        ignore_bins ig4 = binsof(PTE_rw_spage_d.leaflvl_r_1);
    }
    spage_nowrite_s_d: cross PTE_rw_spage_d, PageType_d, mode, Mcause, write_acc, priv_mode, sum_sstatus { //pte.5 & 6
        ignore_bins ig1 = binsof(priv_mode.U_mode);
        ignore_bins ig2 = binsof(PTE_rw_spage_d.leaflvl_r_0);
        ignore_bins ig3 = binsof(PTE_rw_spage_d.leaflvl_r_1);
        ignore_bins ig4 = binsof(PTE_rw_spage_d.leaflvl_w_1);
        ignore_bins ig5 = binsof(Mcause.ins_page_fault);
        ignore_bins ig6 = binsof(Mcause.load_page_fault);
    }

    spage_rwx_s_i_noexec: cross PTE_spage_i, PageType_i, mode, Mcause, exec_acc, priv_mode { //pte.7
        ignore_bins ig1 = binsof(Mcause.load_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(priv_mode.S_mode);
    }
    spage_rwx_s_d_noread: cross PTE_spage_d, PageType_d, mode, Mcause, read_acc, priv_mode {  //pte.7
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(priv_mode.S_mode);
    }
    spage_rwx_s_d_nowrite: cross PTE_spage_d, PageType_d, mode, Mcause, write_acc, priv_mode { //pte.7
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(priv_mode.S_mode);
    } 

    upage_smode_sumunset_noexec_s: cross PTE_upage_i, PageType_i, mode, Mcause, exec_acc, priv_mode , sum_sstatus { //pte.8
        ignore_bins ig1 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(priv_mode.U_mode);
        ignore_bins ig4 = binsof(sum_sstatus.set);
    }
    upage_smode_sumunset_noread_s: cross PTE_upage_d, PageType_d, mode, Mcause, read_acc, priv_mode , sum_sstatus { //pte.8
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(priv_mode.U_mode);
        ignore_bins ig4 = binsof(sum_sstatus.set);
    }
    upage_smode_sumunset_nowrite_s: cross PTE_upage_d, PageType_d, mode, Mcause, write_acc, priv_mode, sum_sstatus { //pte.8
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(priv_mode.U_mode);
        ignore_bins ig4 = binsof(sum_sstatus.set);
    }
    
    upage_smode_sumset_noexec_s: cross PTE_upage_i, PageType_i, mode, Mcause, exec_acc, priv_mode , sum_sstatus { //pte.8 & 9
        ignore_bins ig1 = binsof(Mcause.load_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
    }
    upage_smode_sumset_read_s: cross PTE_upage_d, PageType_d, mode,  Nopagefault, read_acc, priv_mode , sum_sstatus  { //pte.9
        ignore_bins ig1 = binsof(priv_mode.U_mode);
        ignore_bins ig2 = binsof(sum_sstatus.notset);
    }
    upage_smode_sumset_write_s: cross PTE_upage_d, PageType_d, mode,  Nopagefault, write_acc, priv_mode, sum_sstatus  { //pte.9
        ignore_bins ig1 = binsof(priv_mode.U_mode);
        ignore_bins ig2 = binsof(sum_sstatus.notset);
    }

    upage_umode_exec_u: cross PTE_x_upage_i, PageType_i, mode, Nopagefault, exec_acc, priv_mode { //pte.10
        ignore_bins ig1 = binsof(priv_mode.S_mode);
        ignore_bins ig2 = binsof(PTE_x_upage_i.leaflvl_x_0);
    }
    upage_umode_noexec_u: cross PTE_x_upage_i, PageType_i, mode, Mcause, exec_acc, priv_mode { //pte.10
        ignore_bins ig1 =  binsof(Mcause.load_page_fault);
        ignore_bins ig2 =  binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(priv_mode.S_mode);
        ignore_bins ig4 = binsof(PTE_x_upage_i.leaflvl_x_1);
    }

    upage_umode_read_u: cross PTE_rw_upage_d, PageType_d, mode,  Nopagefault, read_acc, priv_mode { //pte.10
        ignore_bins ig1 = binsof(PTE_rw_upage_d.leaflvl_r_0);
        ignore_bins ig2 = binsof(PTE_rw_upage_d.leaflvl_w_0);
        ignore_bins ig3 = binsof(PTE_rw_upage_d.leaflvl_w_1);
        ignore_bins ig4 = binsof(priv_mode.S_mode);   
    }
    upage_umode_noread_u: cross PTE_rw_upage_d, PageType_d, mode,  Mcause, read_acc, priv_mode { //pte.10
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(priv_mode.S_mode);
        ignore_bins ig4 = binsof(PTE_rw_upage_d.leaflvl_r_1);
        ignore_bins ig5 = binsof(PTE_rw_upage_d.leaflvl_w_0);
        ignore_bins ig6 = binsof(PTE_rw_upage_d.leaflvl_w_1);
    }

    upage_umode_write_u: cross PTE_rw_upage_d, PageType_d, mode, Nopagefault, write_acc, priv_mode { //pte.10
        ignore_bins ig1 = binsof(PTE_rw_upage_d.leaflvl_r_0);
        ignore_bins ig2 = binsof(PTE_rw_upage_d.leaflvl_w_0);
        ignore_bins ig3 = binsof(PTE_rw_upage_d.leaflvl_r_1);
        ignore_bins ig4 = binsof(priv_mode.S_mode);
    }
    upage_umode_nowrite_u: cross PTE_rw_upage_d, PageType_d, mode, Mcause, write_acc, priv_mode { //pte.10
        ignore_bins ig1 = binsof(PTE_rw_upage_d.leaflvl_r_0);
        ignore_bins ig2 = binsof(PTE_rw_upage_d.leaflvl_r_1);
        ignore_bins ig3 = binsof(PTE_rw_upage_d.leaflvl_w_1);
        ignore_bins ig4 = binsof(Mcause.ins_page_fault);
        ignore_bins ig5 = binsof(Mcause.load_page_fault);
        ignore_bins ig6 = binsof(priv_mode.S_mode);
    }

    xpage_mxrunset_read_s: cross PTE_XnoRW_d, PageType_d, mode, Mcause, read_acc, mxr_sstatus { //pte.11
        ignore_bins ig1 = binsof(mxr_sstatus.set);
        ignore_bins ig2 = binsof(Mcause.ins_page_fault);
        ignore_bins ig3 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig4 = binsof(PTE_XnoRW_d.leaflvl_u);
    }
    xpage_mxrunset_read_u: cross PTE_XnoRW_d, PageType_d, mode, Mcause, read_acc, mxr_sstatus { //pte.11
        ignore_bins ig1 = binsof(mxr_sstatus.set);
        ignore_bins ig2 = binsof(Mcause.ins_page_fault);
        ignore_bins ig3 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig4 = binsof(PTE_XnoRW_d.leaflvl_s);
    }

    xpage_mxrset_read_s: cross PTE_XnoRW_d, PageType_d, mode, Nopagefault, mxr_sstatus, read_acc { //pte.12
        ignore_bins ig1 = binsof(mxr_sstatus.notset);
        ignore_bins ig2 = binsof(PTE_XnoRW_d.leaflvl_u);
    }
    xpage_mxrset_read_u: cross PTE_XnoRW_d, PageType_d, mode, Nopagefault, mxr_sstatus, read_acc { //pte.12
        ignore_bins ig1 = binsof(mxr_sstatus.notset);
        ignore_bins ig2 = binsof(PTE_XnoRW_d.leaflvl_s);
    }

    Abit_unset_exec_s: cross PTE_Abit_unset_i, PageType_i, mode, Mcause, exec_acc { //pte.14
        ignore_bins ig1 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_Abit_unset_i.leaflvl_u);
    }
    Abit_unset_exec_u: cross PTE_Abit_unset_i, PageType_i, mode, Mcause, exec_acc { //pte.14
        ignore_bins ig1 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_Abit_unset_i.leaflvl_s);
    }

    Abit_unset_read_s: cross PTE_Abit_unset_d, PageType_d, mode, Mcause, read_acc { //pte.14
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(PTE_Abit_unset_d.leaflvl_u);
    }
    Abit_unset_read_u: cross PTE_Abit_unset_d, PageType_d, mode, Mcause, read_acc { //pte.14
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(PTE_Abit_unset_d.leaflvl_s);
    }

    Abit_unset_write_s: cross PTE_Abit_unset_d, PageType_d, mode, Mcause, write_acc { //pte.14
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_Abit_unset_d.leaflvl_u);
    }
    Abit_unset_write_u: cross PTE_Abit_unset_d, PageType_d, mode, Mcause, write_acc { //pte.14
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_Abit_unset_d.leaflvl_s);
    }

    Dbit_set_w_write_s: cross PTE_Dbit_set_W_d, PageType_d, mode, Mcause, write_acc { //pte.15
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_Dbit_set_W_d.leaflvl_u);
    }
    Dbit_set_w_write_u: cross PTE_Dbit_set_W_d, PageType_d, mode, Mcause, write_acc { //pte.15
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_Dbit_set_W_d.leaflvl_s);
    }

    misaligned_exec_s: cross PTE_RWX_i, misaligned_PPN_i, mode, Mcause, exec_acc  { //pte.16
        ignore_bins ig1 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_RWX_i.leaflvl_u);
    }
    misaligned_exec_u: cross PTE_RWX_i, misaligned_PPN_i, mode, Mcause, exec_acc  { //pte.16
        ignore_bins ig1 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_RWX_i.leaflvl_s);
    }

    misaligned_read_s: cross PTE_RWX_d, misaligned_PPN_d, mode, Mcause, read_acc { //pte.16
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(PTE_RWX_d.leaflvl_u);
    }
    misaligned_read_u: cross PTE_RWX_d, misaligned_PPN_d, mode, Mcause, read_acc  { //pte.16
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.store_amo_page_fault);
        ignore_bins ig3 = binsof(PTE_RWX_d.leaflvl_s);
    }

    misaligned_write_s: cross PTE_RWX_d, misaligned_PPN_d, mode, Mcause, write_acc  { //pte.16
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_RWX_d.leaflvl_u);
    }
    misaligned_write_u: cross PTE_RWX_d, misaligned_PPN_d, mode, Mcause, write_acc  { //pte.16
        ignore_bins ig1 = binsof(Mcause.ins_page_fault);
        ignore_bins ig2 = binsof(Mcause.load_page_fault);
        ignore_bins ig3 = binsof(PTE_RWX_d.leaflvl_s);
    }

endgroup

covergroup res_global_pte_cg with function sample(ins_rv32vm_t ins); 
    option.per_instance = 0; 
    //pte.1
    RSW: coverpoint ins.current.PTE_i[9:8] {
        bins all_comb[] = {[2'd0:2'd3]}; 
    }      
    mode: coverpoint  ins.current.csr[12'h180][31] {
        bins sv32   = {1'b1};
    }
    rsw_pte: cross RSW, mode;

    //pte.13
    global_PTE_i: coverpoint ins.current.PTE_i[7:0] {
        wildcard bins leaflvl_u = {8'b??111111};
        wildcard bins leaflvl_s = {8'b??101111};
    }
    global_PTE_d: coverpoint ins.current.PTE_d[7:0] {
        wildcard bins leaflvl_u = {8'b??111111};
        wildcard bins leaflvl_s = {8'b??101111};
    }

    PageType_i: coverpoint ins.current.PageType_i {
        bins mega = {2'b01};
        bins kilo = {2'd0};
    }

    PageType_d: coverpoint ins.current.PageType_d {
        bins mega = {2'b01};
        bins kilo = {2'd0};
    }

    exec_acc: coverpoint ins.current.ExecuteAccess {
        bins set = {1};
    }
    read_acc : coverpoint ins.current.ReadAccess {
        bins set = {1};
    }
    write_acc: coverpoint ins.current.WriteAccess {
        bins set = {1};
    }

    global_PTE_perm_s_i_exec: cross global_PTE_i, PageType_i, mode, exec_acc {
        ignore_bins ig1 = binsof(global_PTE_i.leaflvl_u);
    }

    global_PTE_perm_u_i_exec: cross global_PTE_i, PageType_i, mode, exec_acc {
        ignore_bins ig1 = binsof(global_PTE_i.leaflvl_s);
    }

    global_PTE_perm_s_d_read: cross global_PTE_d, PageType_d, mode, read_acc {
        ignore_bins ig1 = binsof(global_PTE_d.leaflvl_u);
    }

    global_PTE_perm_u_d_read: cross global_PTE_d, PageType_d, mode, read_acc {
        ignore_bins ig1 = binsof(global_PTE_d.leaflvl_s);
    }

    global_PTE_perm_s_d_write: cross global_PTE_d, PageType_d, mode, write_acc {
        ignore_bins ig1 = binsof(global_PTE_d.leaflvl_u);
    }

    global_PTE_perm_u_d_write: cross global_PTE_d, PageType_d, mode, write_acc {
        ignore_bins ig1 = binsof(global_PTE_d.leaflvl_s);
    }

endgroup

covergroup add_feature_cg with function sample(ins_rv32vm_t ins);
    option.per_instance = 0; 
    mode: coverpoint  ins.current.csr[12'h180][31] {
        bins sv32   = {1'b1};
    }

    //pte.18
    menvcfgh: coverpoint  ins.current.csr[12'h31A][29] {
        bins ADUE = {1'b0};
    }
    svadu_not_supported: cross menvcfgh, mode;
endgroup

function void rv32vm_sample(int hart, int issue);
        ins_rv32vm_t ins;
        ins = new(hart, issue, traceDataQ); 
        ins.add_csr(0);
        ins.add_vm_signals(1);
        
        PA_VA_cg.sample(ins);
        satp_cg.sample(ins);
        sfence_cg.sample(ins);
        mstatus_mprv_cg.sample(ins);
        vm_permissions_cg.sample(ins);
        res_global_pte_cg.sample(ins);
        add_feature_cg.sample(ins);
endfunction

   
