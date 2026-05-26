// Code your testbench here
// or browse Examples
class transaction;
  
  bit rst,clk;
  bit w_en,r_en;
  randc bit [7:0] w_d;
  bit [7:0] r_d;
  bit full,emt;
  
endclass
/////////////////////////////////////////
class generator;
  transaction t;
  mailbox #(transaction) mbx;
  event done;
  event next;
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
    t=new();
  endfunction
  
  task run;
    
    for(int i=0;i<32;i++) begin
      assert(t.randomize) else $error("RANDOMIZATION FAILS");
      mbx.put(t);
      @(next);
    end
    ->done;
    
  endtask
  
  
endclass
///////////////////////////////////////////////////////////
class driver;
  virtual f_in fi; 
  transaction td;
  mailbox #(transaction) mbx;
  int i;
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction
  
  event di;
  
  task run;
    //reset();
    forever begin
     
      mbx.get(td);
      
      while (!fi.full) begin
      	write_till_full();
      end
      
      while (!fi.emt) begin
      	read_till_empty();
      end
      
    end
  endtask
  
  task reset();
    @(posedge fi.clk);
    fi.rst<=1'b1;
    repeat(5) @(posedge fi.clk);
    fi.rst<=1'b0;
  endtask
  
  task write_till_full();
   
    begin
      
      fi.rst<=1'b0;
    
      fi.w_en<=1'b1;
      fi.r_en<=1'b0;
      fi.w_d<=td.w_d;
      @(posedge fi.clk);
      fi.w_en<=1'b0;
     
      @(posedge fi.clk);
    end
  endtask
  
  task read_till_empty();
    
      
      fi.rst<=1'b0;
     
      fi.r_en<=1'b1;
      fi.w_en<=1'b0;
      @(posedge fi.clk);
      fi.r_en<=1'b0;
      
      @(posedge fi.clk);
    
  endtask
  
  
  
endclass
////////////////////////////////////////////////////////
class monitor;
  virtual f_in fi;
  transaction tm;
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
    tm=new();
  endfunction
  
  task run();
    
    forever begin
      tm=new();
      @(posedge fi.clk);
      tm.w_en=fi.w_en;
      tm.r_en=fi.r_en;
      tm.w_d=fi.w_d;
      @(posedge fi.clk);
      tm.r_d=fi.r_d;
      mbx.put(tm);
    end
  endtask
  
endclass
///////////////////////////////////////////////////////////////
class scoreboard;
  transaction ts;
  mailbox #(transaction) mbx;
  event next;
  int i=0;
  
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction
  
  task run;
    
    forever begin
      mbx.get(ts);
      if(i<16) begin
        $display("W--------------------- %0d",ts.w_d);
        i++;
      end
      else begin
        $display("R--------------------- %0d",ts.r_d);
        i++;
      end
      
      -> next;
    end
    
    
  endtask
  
  
endclass
//////////////////////////////////////////////////////////////////
module FIFO_tb;
  
  f_in fi();
  FIFO dut(.w_en(fi.w_en),.r_en(fi.r_en),.rst(fi.rst),.clk(fi.clk),.w_d(fi.w_d),.r_d(fi.r_d),.full(fi.full),.emt(fi.emt));
  
  generator g;
  driver d;
  monitor m;
  scoreboard s;
  mailbox #(transaction) mbx1;
  mailbox #(transaction) mbx2;  
  event done;
  event next;
  
  initial begin
    mbx1=new();
    mbx2=new();
    g=new(mbx1);
    d=new(mbx1);
    m=new(mbx2);
    s=new(mbx2);
    d.fi=fi;
    m.fi=fi;
    g.done=done;
  	s.next=next;
    g.next=next;
   
  end
  
  
  
  initial begin
    fi.clk<=0;
  end
  
  always #10 fi.clk <= ~fi.clk;
  
  
  
  initial begin
    d.reset;
    fork
      g.run;
      d.run;
      m.run;
      s.run;
    join_any
    wait(done.triggered);
    $finish();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  
endmodule
