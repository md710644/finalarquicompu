// filename: definesPkg.vh
  //=================================================
 // TypeDefs declaration
 //=================================================
 package definesPkg;
 typedef struct {
     logic [7:0] Type;
     logic [7:0] Size;
  } Theader;
  
    typedef struct {
     logic [7:0] Start;
     Theader Header;
	  logic [63:0] Data;
     logic [7:0] Error;
	  logic [7:0] End; 
	  
  } Tdata_sb;
  
   typedef struct {
	  logic [7:0] Address_code;
	  logic [15:0] Page_reference;
	} Taddress;
	
	typedef enum logic [1:0] {
	  INV = 2'b00,
	  MOD = 2'b01,
	  EXC = 2'b10, 
	  SHD = 2'b11
	} Tmesi_state;
	
endpackage 