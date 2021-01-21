module test_fpadder;

logic [31:0] sum; 
logic ready;
logic [31:0] a;
logic clock, nreset;
shortreal reala, realsum;

logic [31:0] m,n;
assign m = a1.m;
assign n = a1.n;



fpadder a1 (.*);

initial
  begin
  nreset = '1;
  clock = '0;
  #5ns nreset = '1;
  #5ns nreset = '0;
  #5ns nreset = '1;
  forever #5ns clock = ~clock;
  end
  
initial
  begin
  //Test 1 -- reset
  @(posedge ready); // wait for ready
  
  //Test 2 -- 1.0 + 1.0 
  @(posedge clock); //wait for next clock tick
  reala = 1.0;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = 1.0;
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 2 %f\n", realsum);
  
  //Test 3 -- 42.0 + 3.14159 
  //@(posedge clock);
  reala = 42.0;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = 3.14159;
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 3 %f\n", realsum);
  
    //Test 3 -- 1.0 + -1.0 
  //@(posedge clock);
  reala = 1.0;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = -1.0;
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 3 %f\n", realsum);
  
      //Test 3 -- 0.0 + 0.0 
  //@(posedge clock);
  reala = 0.0;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = 0.0;
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 3 %f\n", realsum);
  
  
  //next test
    //Test 4 -- -11.896 + 3.896
  //@(posedge clock);
  reala = -11.896;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = 3.896;
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 4 %f\n", realsum);
  
    //next test
    //Test 4 -- -2.977734e25
  //@(posedge clock);
  reala = -2.977734e+25;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = 5.493647e-4;
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 4 %f\n", realsum);
  
   reala = 1.4565;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = (1.0/0.0);
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 4 %f\n", realsum);
  
  //Test 11 -- 1.0 + NaN 
  //@(posedge clock);
  reala = 1.0;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = (0.0/0.0);
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 12 %f\n", realsum);
  
   reala = 1.0;
  a = $shortrealtobits(reala);
  @(posedge clock);
  reala = -1.0;
  a = $shortrealtobits(reala);
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal(sum);
  $display("Test 12 %f\n", realsum);
  
  #100ns $stop;
  end
endmodule
  