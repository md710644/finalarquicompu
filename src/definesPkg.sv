// filename: definesPkg.vh
  //=================================================
 // TypeDefs declaration
 //=================================================
 package definesPkg;
 typedef struct {
     logic [7:0] Type;//Read, Write, Grant, retry, req_bus
     logic [7:0] Size;// pensar despues
  } Theader;
  
    typedef struct {
     logic [7:0] Start;
     Theader Header;
	  logic [31:0] Data;//Data and address or just Data? Does it includes the MESI ST?
     logic [7:0] Error;
	  logic [7:0] End; 
	  
  } Tdata_sb;
  
   typedef struct {
	  logic [7:0] Index;
	  logic [15:0] Page_reference;
	} Taddress;
	
	typedef enum logic [1:0] {
	  INV = 2'b00,
	  MOD = 2'b01,
	  EXC = 2'b10, 
	  SHD = 2'b11
	} Tmesi_state;
	
endpackage 