__BEGIN_DECLS

extern void     axi_mm_out32(uint32_t addr, uint32_t d);
extern uint32_t axi_mm_in32 (uint32_t addr);

extern size_t   mem_size;
extern unsigned char *mem0;

__END_DECLS
