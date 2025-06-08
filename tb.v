`timescale 1ns/1ps

module tb();

    reg  [3:0]  ALU_OP_i;
    reg  [31:0] ALU_RS1_i;
    reg  [31:0] ALU_RS2_i;
    wire [31:0] ALU_RD_o;
    wire        ALU_ZR_o;

    parameter MEMFILE = "teste.txt";

    reg [103:0] test_mem [0:512]; // 4+32+32+32+4 = 104 bits
    reg [31:0] expected_rd;
    reg expected_zero;
    integer i;

    // Instância da ALU
    Alu uut (
        .ALU_OP_i  (ALU_OP_i),
        .ALU_RS1_i (ALU_RS1_i),
        .ALU_RS2_i (ALU_RS2_i),
        .ALU_RD_o  (ALU_RD_o),
        .ALU_ZR_o  (ALU_ZR_o)
    );

    initial begin
        $dumpfile("saida.vcd");
        $dumpvars(0, tb);

        $display("Iniciando Testbench...");
        $readmemh(MEMFILE, test_mem);

        for (i = 0; i < 324; i = i + 1) begin
            if (^test_mem[i] === 1'bx) begin
                $display("Fim dos testes ou entrada inválida em linha %0d", i);
                $finish;
            end

            // Separar os campos: opcode_rs1_rs2_rd_0
            // test_mem[i] = {opcode[3:0], rs1[31:0], rs2[31:0], rd[31:0], zero[3:0]}
            ALU_OP_i   = test_mem[i][103:100];
            ALU_RS1_i  = test_mem[i][99:68];
            ALU_RS2_i  = test_mem[i][ 67: 36];
            expected_rd= test_mem[i][ 35: 4];
            expected_zero = test_mem[i][ 3: 0] != 4'b0000; // se zero for diferente de 0, é esperado que ALU_ZR_o seja 1

            #1; // aguarda propagação

            if (ALU_RD_o === expected_rd) begin
                $display("=== OK  [%0d] OP:%h RS1:%h RS2:%h => RD:%h (esperado)", i, ALU_OP_i, ALU_RS1_i, ALU_RS2_i, ALU_RD_o);
            end else begin
                $display("=== ERRO[%0d] OP:%h RS1:%h RS2:%h => RD:%h (esperado: %h)", i, ALU_OP_i, ALU_RS1_i, ALU_RS2_i, ALU_RD_o, expected_rd);
            end

            #5; // espaçamento entre testes
        end

        $display("Testbench finalizado com sucesso.");
        $finish;
    end

endmodule
