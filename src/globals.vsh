// filename: definesPkg.vh

package definesPkg;
  //=================================================
 // TypeDefs declaration
 //=================================================
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
	
	endpackage
	
	