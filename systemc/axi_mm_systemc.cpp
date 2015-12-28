#include <systemc.h>
#include "axi_mm_systemc.h"
#include "oschip_api.h"

SC_MODULE(axi_mm_systemc)
{ 
public:
    /*Master Interface System Signals*/
    sc_in <bool>            	axi_aclk;
    /* Master Interface Write Address Port*/
   sc_out < sc_uint<32> >       m_axi_awaddr;
   sc_out < sc_uint<8> >      	m_axi_awlen;
   sc_out < sc_uint<3> >      	m_axi_awsize;
//   sc_out < sc_uint<4> >      	m_axi_awuser;
   sc_out < sc_uint<2> >  	m_axi_awburst;
   sc_out < sc_uint<3> >  	m_axi_awprot;
   sc_out <bool>              	m_axi_awvalid;
   sc_in <bool>                	m_axi_awready;
   /* Master Interface Write Data Ports*/
   sc_out < sc_uint<32> >    	m_axi_wdata;
   sc_out < sc_uint<4> >  	m_axi_wstrb;
   sc_out <bool>          	m_axi_wlast;
//   sc_out  < sc_uint<4> >       m_axi_wuser;
   sc_out <bool>         	m_axi_wvalid;
   sc_in <bool>        		m_axi_wready;
   /* Master Interface Write Response Ports*/
   sc_in < sc_uint<2> >     	m_axi_bresp;
//   sc_in < sc_uint<3> >    	m_axi_buser;
   sc_in <bool>         	m_axi_bvalid;
   sc_out <bool>              	m_axi_bready;
   /* Master Interface Read Address Port*/
   sc_out < sc_uint<32> >       m_axi_araddr;
   sc_out < sc_uint<8> >    	m_axi_arlen;
   sc_out < sc_uint<3> >    	m_axi_arsize;
   sc_out < sc_uint<2> >  	m_axi_arburst;
   sc_out < sc_uint<3> >  	m_axi_arprot;
//   sc_out < sc_uint<4> >      	m_axi_aruser;
   sc_out <bool>             	m_axi_arvalid;
   sc_in <bool>           	m_axi_arready;
   /* Master Interface Read Data Ports*/
   sc_in < sc_uint<32> >    	m_axi_rdata;
   sc_in < sc_uint<2> >       	m_axi_rresp;
   sc_in <bool>             	m_axi_rlast;
//   sc_in < sc_uint<4> >       	m_axi_ruser;
   sc_in <bool>           	m_axi_rvalid;
   sc_out <bool>          	m_axi_rready;

   // slave interface write address ports
   sc_in <bool> BRAM_Rst_A;
   sc_in <bool> BRAM_Clk_A;
   sc_in <bool> BRAM_En_A;
   sc_in  < sc_uint<4> > BRAM_WE_A;
   sc_in  < sc_uint<32> > BRAM_Addr_A;
   sc_in  < sc_uint<32> > BRAM_WrData_A;
   sc_out < sc_uint<32> > BRAM_RdData_A;
   sc_in <bool> BRAM_Rst_B;
   sc_in <bool> BRAM_Clk_B;
   sc_in <bool> BRAM_En_B;
   sc_in  < sc_uint<4> > BRAM_WE_B;
   sc_in  < sc_uint<32> > BRAM_Addr_B;
   sc_in  < sc_uint<32> > BRAM_WrData_B;
   sc_out < sc_uint<32> > BRAM_RdData_B;

   sc_in <bool>           interrupt;
   sc_in <bool>           ready;

   void axi_intr(void);

   /* master */
   void iomem_out32(uint32_t off, uint32_t val);
   uint32_t iomem_in32(uint32_t off);
   void axi_mm_master_init(void);

   /* slave */
   void bram_mem_porta(void);
   void bram_mem_portb(void);

    SC_CTOR(axi_mm_systemc)
    {
	    SC_THREAD(axi_mm_master_init);

	    SC_METHOD(axi_intr);
	    sensitive_pos << axi_aclk;

	    SC_METHOD(bram_mem_porta);
	    sensitive_pos << BRAM_Clk_A;

	    SC_METHOD(bram_mem_portb);
	    sensitive_pos << BRAM_Clk_B;
    };

    ~axi_mm_systemc()
    {
    }
};

void axi_mm_systemc::iomem_out32(uint32_t off, uint32_t val)
{
        if ((off >> 2) & 0x1  == 0x1) { 
		m_axi_wstrb.write(0xf0);
	} else {
		m_axi_wstrb.write(0x0f);
	}

	m_axi_awaddr.write(off);
	m_axi_awlen.write(0x0);   
	m_axi_awsize.write(0x1);
	m_axi_awburst.write(0x1);
	m_axi_awprot.write(0x2);
	//m_axi_awuser.write(0xf);

	m_axi_wdata.write(val);
	//m_axi_wuser.write();

	m_axi_awvalid.write(1);
	for(;;) {
		if (m_axi_awready.read()) {
			break;
		}
		wait (axi_aclk->posedge_event());
	}
	m_axi_awvalid.write(0);

	m_axi_wvalid.write(1);
	m_axi_wlast.write(1);
	for(;;) {
		if (m_axi_wready.read())
			break;
		wait (axi_aclk->posedge_event());
	}
	m_axi_wvalid.write(0);
	m_axi_wlast.write(0);

	for(;;) {
		if (m_axi_bvalid.read() /*&& m_axi_bresp.read() == 0x0*/) {
			m_axi_bready.write(1);
			break;
		}	
		wait (axi_aclk->posedge_event());
	}
	wait (axi_aclk->posedge_event());
	m_axi_bready.write(0);
}

uint32_t axi_mm_systemc::iomem_in32(uint32_t off)
{
	uint32_t val;
	m_axi_araddr.write(off);
	m_axi_arlen.write(0x0);
	m_axi_arsize.write(0x1);
	m_axi_arburst.write(0x1);
	m_axi_arprot.write(0x2);
//	m_axi_aruser.write(0xf);

	m_axi_arvalid.write(1);
	for(;;) {
		if (m_axi_arready.read()) {
			break;
		}
		wait (axi_aclk->posedge_event());
	}
	m_axi_arvalid.write(0);

	for(;;) {
		if (m_axi_rvalid.read()) {
			val = m_axi_rdata.read();
			m_axi_rready.write(1);
			break;
		}
		wait (axi_aclk->posedge_event());
	}
	wait (axi_aclk->posedge_event());
	m_axi_rready.write(0);

	return val;
}

static axi_mm_systemc *obj;

void axi_mm_out32(uint32_t addr, uint32_t val)
{
	obj->iomem_out32(addr, val);
}

uint32_t axi_mm_in32 (uint32_t addr)
{
	return obj->iomem_in32(addr);
}

static uint32_t base = 0x73600000;

uint32_t osChipRegRead(uint32_t chipOffset)
{
	return obj->iomem_in32(chipOffset);
}

void osChipRegWrite(uint32_t chipOffset, uint32_t chipValue)
{
	obj->iomem_out32(chipOffset, chipValue);
}
const char *systemc_time(void)
{
	return sc_time_stamp().to_string().c_str();
}
void systemc_sc_stop(void)
{
	sc_core::sc_stop();
}
void axi_mm_systemc::axi_mm_master_init(void)
{
	int i;

	printf("calling %s, %d\n", __func__, __LINE__);
	obj = this;

	printf("calling %s, %d\n", __func__, __LINE__);
	for (i = 0; i < 100; i++) 
		wait (axi_aclk->posedge_event());
	
	for (i = 0; ready.read() == 0; i++) 
		wait (axi_aclk->posedge_event());

	printf("calling %s, %d\n", __func__, __LINE__);
	osChip_init(base);

	printf("calling %s, %d\n", __func__, __LINE__);
	for (;;) {
		wait (axi_aclk->posedge_event());
		if (interrupt.read())
			osChip_interrupt(base);
		wait (axi_aclk->posedge_event());
	}
}

void axi_mm_systemc::axi_intr(void)
{
}

void axi_mm_systemc::bram_mem_porta(void)
{
	uint32_t val, rval;
	uint32_t addr;
	uint32_t we;

	if (BRAM_En_A.read() == 0) 
		return;

	addr = BRAM_Addr_A.read();
	addr &= (mem_size-1);

	val  = BRAM_WrData_A.read();
	we   = BRAM_WE_B.read();

	if (we & 1)
		mem0[addr+0] = val >> 0;
	if (we & 2)
		mem0[addr+1] = val >> 8;
	if (we & 4)
		mem0[addr+2] = val >> 16;
	if (we & 8)
		mem0[addr+3] = val >> 24;

	rval =  (mem0[addr+0] << 0 ) |
		(mem0[addr+1] << 8 ) |
		(mem0[addr+2] << 16) |
		(mem0[addr+3] << 24);

	BRAM_RdData_A.write(rval);
}

void axi_mm_systemc::bram_mem_portb(void)
{
	uint32_t val, rval;
	uint32_t addr;
	uint32_t we;

	if (BRAM_En_B.read() == 0) 
		return;

	addr = BRAM_Addr_B.read();
	addr &= (mem_size-1);

	val  = BRAM_WrData_B.read();
	we   = BRAM_WE_B.read();

	if (we & 1)
		mem0[addr+0] = val >> 0;
	if (we & 2)
		mem0[addr+1] = val >> 8;
	if (we & 4)
		mem0[addr+2] = val >> 16;
	if (we & 8)
		mem0[addr+3] = val >> 24;

	rval =  (mem0[addr+0] << 0 ) |
		(mem0[addr+1] << 8 ) |
		(mem0[addr+2] << 16) |
		(mem0[addr+3] << 24);

	BRAM_RdData_B.write(rval);
}

SC_MODULE_EXPORT(axi_mm_systemc);
