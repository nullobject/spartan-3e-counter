BUILD_DIR = build
DEVICE = xc3s500e-4-fg320

all: $(BUILD_DIR)/counter.bit

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/counter.ngc: counter.vhd | $(BUILD_DIR)
	@cd $(BUILD_DIR); \
	echo "run -ifn ../counter.vhd -ifmt VHDL -ofn counter -p $(DEVICE) -opt_mode Speed -opt_level 1" | xst

$(BUILD_DIR)/counter.ngd: spartan-3e.ucf $(BUILD_DIR)/counter.ngc
	@cd $(BUILD_DIR); \
	ngd$(BUILD_DIR) -p $(DEVICE) -uc ../spartan-3e.ucf counter.ngc

$(BUILD_DIR)/counter.ncd: $(BUILD_DIR)/counter.ngd
	@cd $(BUILD_DIR); \
	map -detail -pr b counter.ngd

# counter.pcf: counter.ngd
# 	@cd $(BUILD_DIR); \
# 	map -detail -pr b counter.ngd

$(BUILD_DIR)/parout.ncd: $(BUILD_DIR)/counter.ncd
	@cd $(BUILD_DIR); \
	par -w counter.ncd parout.ncd counter.pcf

$(BUILD_DIR)/counter.bit: $(BUILD_DIR)/parout.ncd
	@cd $(BUILD_DIR); \
	bitgen -g CRC:Enable -g StartUpClk:CClk -g Compress -w parout.ncd counter.bit counter.pcf

clean:
	rm -rf $(BUILD_DIR)

program: $(BUILD_DIR)/counter.bit
	@cd $(BUILD_DIR); \
	echo "setMode -bs" > impact.cmd; \
	echo "setCable -port auto" >> impact.cmd; \
	echo "Identify -inferir" >> impact.cmd; \
	echo "assignFile -p 1 -file counter.bit" >> impact.cmd; \
	echo "Program -p 1" >> impact.cmd; \
	echo "exit" >> impact.cmd; \
	impact -batch impact.cmd
