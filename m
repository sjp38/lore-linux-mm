Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 77F376B0005
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 21:00:02 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id le9so249418655pab.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 18:00:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id y186si39663046pfb.59.2016.08.08.18.00.01
        for <linux-mm@kvack.org>;
        Mon, 08 Aug 2016 18:00:01 -0700 (PDT)
Date: Tue, 9 Aug 2016 09:04:23 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-stable-rc:linux-3.14.y 1941/4855]
 arch/mips/jz4740/irq.c:62:6: error: conflicting types for
 'jz4740_irq_suspend'
Message-ID: <201608090921.ZFF5cAHU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sasha,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-3.14.y
head:   80b848303c2e36c5029a8cbde4f3287abbd796bd
commit: 017ff97daa4a7892181a4dd315c657108419da0c [1941/4855] kernel: add support for gcc 5
config: mips-jz4740 (attached as .config)
compiler: mipsel-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 017ff97daa4a7892181a4dd315c657108419da0c
        # save the attached .config to linux build tree
        make.cross ARCH=mips 

All errors (new ones prefixed by >>):

   In file included from arch/mips/include/asm/irq.h:18:0,
                    from include/linux/irq.h:24,
                    from include/asm-generic/hardirq.h:12,
                    from arch/mips/include/asm/hardirq.h:16,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from arch/mips/jz4740/irq.c:19:
   arch/mips/jz4740/irq.h:20:39: warning: 'struct irq_data' declared inside parameter list
    extern void jz4740_irq_suspend(struct irq_data *data);
                                          ^
   arch/mips/jz4740/irq.h:20:39: warning: its scope is only this definition or declaration, which is probably not what you want
   arch/mips/jz4740/irq.h:21:38: warning: 'struct irq_data' declared inside parameter list
    extern void jz4740_irq_resume(struct irq_data *data);
                                         ^
   In file included from include/linux/irq.h:363:0,
                    from include/asm-generic/hardirq.h:12,
                    from arch/mips/include/asm/hardirq.h:16,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from arch/mips/jz4740/irq.c:19:
   include/linux/irqdesc.h:80:33: error: 'NR_IRQS' undeclared here (not in a function)
    extern struct irq_desc irq_desc[NR_IRQS];
                                    ^
   arch/mips/jz4740/irq.c: In function 'jz4740_cascade':
   arch/mips/jz4740/irq.c:49:39: error: 'JZ4740_IRQ_BASE' undeclared (first use in this function)
      generic_handle_irq(__fls(irq_reg) + JZ4740_IRQ_BASE);
                                          ^
   arch/mips/jz4740/irq.c:49:39: note: each undeclared identifier is reported only once for each function it appears in
   arch/mips/jz4740/irq.c: At top level:
>> arch/mips/jz4740/irq.c:62:6: error: conflicting types for 'jz4740_irq_suspend'
    void jz4740_irq_suspend(struct irq_data *data)
         ^
   In file included from arch/mips/include/asm/irq.h:18:0,
                    from include/linux/irq.h:24,
                    from include/asm-generic/hardirq.h:12,
                    from arch/mips/include/asm/hardirq.h:16,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from arch/mips/jz4740/irq.c:19:
   arch/mips/jz4740/irq.h:20:13: note: previous declaration of 'jz4740_irq_suspend' was here
    extern void jz4740_irq_suspend(struct irq_data *data);
                ^
>> arch/mips/jz4740/irq.c:68:6: error: conflicting types for 'jz4740_irq_resume'
    void jz4740_irq_resume(struct irq_data *data)
         ^
   In file included from arch/mips/include/asm/irq.h:18:0,
                    from include/linux/irq.h:24,
                    from include/asm-generic/hardirq.h:12,
                    from arch/mips/include/asm/hardirq.h:16,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from arch/mips/jz4740/irq.c:19:
   arch/mips/jz4740/irq.h:21:13: note: previous declaration of 'jz4740_irq_resume' was here
    extern void jz4740_irq_resume(struct irq_data *data);
                ^
   arch/mips/jz4740/irq.c: In function 'arch_init_irq':
   arch/mips/jz4740/irq.c:91:41: error: 'JZ4740_IRQ_BASE' undeclared (first use in this function)
     gc = irq_alloc_generic_chip("INTC", 1, JZ4740_IRQ_BASE, jz_intc_base,
                                            ^
--
   arch/mips/kernel/r4k_switch.S: Assembler messages:
>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f0,952($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f2,968($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f4,984($4)'
>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f6,1000($4)'
>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f8,1016($4)'
>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f10,1032($4)'
>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f12,1048($4)'
>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f14,1064($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f16,1080($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f18,1096($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f20,1112($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f22,1128($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f24,1144($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f26,1160($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f28,1176($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f30,1192($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f0,952($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f2,968($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f4,984($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f6,1000($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f8,1016($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f10,1032($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f12,1048($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f14,1064($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f16,1080($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f18,1096($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f20,1112($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f22,1128($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f24,1144($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f26,1160($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f28,1176($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: mips32 (mips32) `sdc1 $f30,1192($4)'
>> arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f0,952($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f2,968($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f4,984($4)'
>> arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f6,1000($4)'
>> arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f8,1016($4)'
>> arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f10,1032($4)'
>> arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f12,1048($4)'
>> arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f14,1064($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f16,1080($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f18,1096($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f20,1112($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f22,1128($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f24,1144($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f26,1160($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f28,1176($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: mips32 (mips32) `ldc1 $f30,1192($4)'
>> arch/mips/kernel/r4k_switch.S:199: Error: opcode not supported on this processor: mips32 (mips32) `mtc1 $9,$f0'
>> arch/mips/kernel/r4k_switch.S:200: Error: opcode not supported on this processor: mips32 (mips32) `mtc1 $9,$f1'
>> arch/mips/kernel/r4k_switch.S:201: Error: opcode not supported on this processor: mips32 (mips32) `mtc1 $9,$f2'
>> arch/mips/kernel/r4k_switch.S:202: Error: opcode not supported on this processor: mips32 (mips32) `mtc1 $9,$f3'
>> arch/mips/kernel/r4k_switch.S:203: Error: opcode not supported on this processor: mips32 (mips32) `mtc1 $9,$f4'
>> arch/mips/kernel/r4k_switch.S:204: Error: opcode not supported on this processor: mips32 (mips32) `mtc1 $9,$f5'
>> arch/mips/kernel/r4k_switch.S:205: Error: opcode not supported on this processor: mips32 (mips32) `mtc1 $9,$f6'
>> arch/mips/kernel/r4k_switch.S:206: Error: opcode not supported on this processor: mips32 (mips32) `mtc1 $9,$f7'

vim +/jz4740_irq_suspend +62 arch/mips/jz4740/irq.c

9869848d Lars-Peter Clausen 2010-07-17  13   *
9869848d Lars-Peter Clausen 2010-07-17  14   */
9869848d Lars-Peter Clausen 2010-07-17  15  
9869848d Lars-Peter Clausen 2010-07-17  16  #include <linux/errno.h>
9869848d Lars-Peter Clausen 2010-07-17  17  #include <linux/init.h>
9869848d Lars-Peter Clausen 2010-07-17  18  #include <linux/types.h>
9869848d Lars-Peter Clausen 2010-07-17 @19  #include <linux/interrupt.h>
9869848d Lars-Peter Clausen 2010-07-17  20  #include <linux/ioport.h>
9869848d Lars-Peter Clausen 2010-07-17  21  #include <linux/timex.h>
9869848d Lars-Peter Clausen 2010-07-17  22  #include <linux/slab.h>
9869848d Lars-Peter Clausen 2010-07-17  23  #include <linux/delay.h>
9869848d Lars-Peter Clausen 2010-07-17  24  
9869848d Lars-Peter Clausen 2010-07-17  25  #include <linux/debugfs.h>
9869848d Lars-Peter Clausen 2010-07-17  26  #include <linux/seq_file.h>
9869848d Lars-Peter Clausen 2010-07-17  27  
9869848d Lars-Peter Clausen 2010-07-17  28  #include <asm/io.h>
9869848d Lars-Peter Clausen 2010-07-17  29  #include <asm/mipsregs.h>
9869848d Lars-Peter Clausen 2010-07-17  30  #include <asm/irq_cpu.h>
9869848d Lars-Peter Clausen 2010-07-17  31  
9869848d Lars-Peter Clausen 2010-07-17  32  #include <asm/mach-jz4740/base.h>
9869848d Lars-Peter Clausen 2010-07-17  33  
9869848d Lars-Peter Clausen 2010-07-17  34  static void __iomem *jz_intc_base;
9869848d Lars-Peter Clausen 2010-07-17  35  
9869848d Lars-Peter Clausen 2010-07-17  36  #define JZ_REG_INTC_STATUS	0x00
9869848d Lars-Peter Clausen 2010-07-17  37  #define JZ_REG_INTC_MASK	0x04
9869848d Lars-Peter Clausen 2010-07-17  38  #define JZ_REG_INTC_SET_MASK	0x08
9869848d Lars-Peter Clausen 2010-07-17  39  #define JZ_REG_INTC_CLEAR_MASK	0x0c
9869848d Lars-Peter Clausen 2010-07-17  40  #define JZ_REG_INTC_PENDING	0x10
9869848d Lars-Peter Clausen 2010-07-17  41  
83bc7692 Lars-Peter Clausen 2011-09-24  42  static irqreturn_t jz4740_cascade(int irq, void *data)
9869848d Lars-Peter Clausen 2010-07-17  43  {
83bc7692 Lars-Peter Clausen 2011-09-24  44  	uint32_t irq_reg;
9869848d Lars-Peter Clausen 2010-07-17  45  
83bc7692 Lars-Peter Clausen 2011-09-24  46  	irq_reg = readl(jz_intc_base + JZ_REG_INTC_PENDING);
9869848d Lars-Peter Clausen 2010-07-17  47  
83bc7692 Lars-Peter Clausen 2011-09-24  48  	if (irq_reg)
83bc7692 Lars-Peter Clausen 2011-09-24 @49  		generic_handle_irq(__fls(irq_reg) + JZ4740_IRQ_BASE);
83bc7692 Lars-Peter Clausen 2011-09-24  50  
83bc7692 Lars-Peter Clausen 2011-09-24  51  	return IRQ_HANDLED;
42b64f38 Thomas Gleixner    2011-03-23  52  }
42b64f38 Thomas Gleixner    2011-03-23  53  
83bc7692 Lars-Peter Clausen 2011-09-24  54  static void jz4740_irq_set_mask(struct irq_chip_generic *gc, uint32_t mask)
9869848d Lars-Peter Clausen 2010-07-17  55  {
83bc7692 Lars-Peter Clausen 2011-09-24  56  	struct irq_chip_regs *regs = &gc->chip_types->regs;
9869848d Lars-Peter Clausen 2010-07-17  57  
83bc7692 Lars-Peter Clausen 2011-09-24  58  	writel(mask, gc->reg_base + regs->enable);
83bc7692 Lars-Peter Clausen 2011-09-24  59  	writel(~mask, gc->reg_base + regs->disable);
9869848d Lars-Peter Clausen 2010-07-17  60  }
9869848d Lars-Peter Clausen 2010-07-17  61  
83bc7692 Lars-Peter Clausen 2011-09-24 @62  void jz4740_irq_suspend(struct irq_data *data)
9869848d Lars-Peter Clausen 2010-07-17  63  {
83bc7692 Lars-Peter Clausen 2011-09-24  64  	struct irq_chip_generic *gc = irq_data_get_irq_chip_data(data);
83bc7692 Lars-Peter Clausen 2011-09-24  65  	jz4740_irq_set_mask(gc, gc->wake_active);
83bc7692 Lars-Peter Clausen 2011-09-24  66  }
9869848d Lars-Peter Clausen 2010-07-17  67  
83bc7692 Lars-Peter Clausen 2011-09-24 @68  void jz4740_irq_resume(struct irq_data *data)
83bc7692 Lars-Peter Clausen 2011-09-24  69  {
83bc7692 Lars-Peter Clausen 2011-09-24  70  	struct irq_chip_generic *gc = irq_data_get_irq_chip_data(data);
83bc7692 Lars-Peter Clausen 2011-09-24  71  	jz4740_irq_set_mask(gc, gc->mask_cache);

:::::: The code at line 62 was first introduced by commit
:::::: 83bc769200802c9ce8fd1c7315fd14198d385b12 MIPS: JZ4740: Use generic irq chip

:::::: TO: Lars-Peter Clausen <lars@metafoo.de>
:::::: CC: Ralf Baechle <ralf@linux-mips.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--T4sUOijqQbZv57TR
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
TH+fX1mG3PoJFb83nj3/D7sSCS+jCAEA

--T4sUOijqQbZv57TR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
