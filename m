Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B61F66B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 08:18:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so370974486pfx.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 05:18:15 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 4si26640403pav.105.2016.07.18.05.18.14
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 05:18:14 -0700 (PDT)
Date: Mon, 18 Jul 2016 20:16:49 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [jirislaby-stable:stable-3.12-queue 2253/5330]
 arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this
 processor: r4600 (mips3) `sdc1 $f0,528($4)'
Message-ID: <201607182032.yz5mrVhT%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Jiri Slaby <jslaby@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/jirislaby/linux-stable.git stable-3.12-queue
head:   948c2b1f570cbf441db7f0fad28f7dcb5b54443d
commit: 478a5f81defe61a89083f3b719e142f250427098 [2253/5330] kernel: add support for gcc 5
config: mips-allnoconfig (attached as .config)
compiler: mips-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 478a5f81defe61a89083f3b719e142f250427098
        # save the attached .config to linux build tree
        make.cross ARCH=mips 

All errors (new ones prefixed by >>):

   arch/mips/kernel/r4k_switch.S: Assembler messages:
>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f0,528($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f2,544($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f4,560($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f6,576($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f8,592($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f10,608($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f12,624($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f14,640($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f16,656($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f18,672($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f20,688($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f22,704($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f24,720($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f26,736($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f28,752($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f30,768($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f0,528($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f2,544($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f4,560($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f6,576($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f8,592($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f10,608($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f12,624($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f14,640($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f16,656($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f18,672($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f20,688($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f22,704($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f24,720($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f26,736($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f28,752($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f30,768($4)'
>> arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f0,528($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f2,544($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f4,560($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f6,576($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f8,592($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f10,608($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f12,624($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f14,640($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f16,656($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f18,672($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f20,688($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f22,704($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f24,720($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f26,736($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f28,752($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f30,768($4)'
>> arch/mips/kernel/r4k_switch.S:233: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f0'
>> arch/mips/kernel/r4k_switch.S:234: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f2'
>> arch/mips/kernel/r4k_switch.S:235: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f4'
>> arch/mips/kernel/r4k_switch.S:236: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f6'
>> arch/mips/kernel/r4k_switch.S:237: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f8'
>> arch/mips/kernel/r4k_switch.S:238: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f10'
>> arch/mips/kernel/r4k_switch.S:239: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f12'
>> arch/mips/kernel/r4k_switch.S:240: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f14'
>> arch/mips/kernel/r4k_switch.S:241: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f16'
>> arch/mips/kernel/r4k_switch.S:242: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f18'
>> arch/mips/kernel/r4k_switch.S:243: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f20'
>> arch/mips/kernel/r4k_switch.S:244: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f22'
>> arch/mips/kernel/r4k_switch.S:245: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f24'
>> arch/mips/kernel/r4k_switch.S:246: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f26'
>> arch/mips/kernel/r4k_switch.S:247: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f28'
>> arch/mips/kernel/r4k_switch.S:248: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f30'

vim +67 arch/mips/kernel/r4k_switch.S

^1da177e Linus Torvalds 2005-04-16   61  	 */
^1da177e Linus Torvalds 2005-04-16   62  	LONG_L	t0, ST_OFF(t3)
^1da177e Linus Torvalds 2005-04-16   63  	li	t1, ~ST0_CU1
^1da177e Linus Torvalds 2005-04-16   64  	and	t0, t0, t1
^1da177e Linus Torvalds 2005-04-16   65  	LONG_S	t0, ST_OFF(t3)
^1da177e Linus Torvalds 2005-04-16   66  
c138e12f Atsushi Nemoto 2006-05-23  @67  	fpu_save_double a0 t0 t1		# c0_status passed in t0
c138e12f Atsushi Nemoto 2006-05-23   68  						# clobbers t1
^1da177e Linus Torvalds 2005-04-16   69  1:
^1da177e Linus Torvalds 2005-04-16   70  
1400eb65 Gregory Fong   2013-06-17   71  #if defined(CONFIG_CC_STACKPROTECTOR) && !defined(CONFIG_SMP)
8b3c569a James Hogan    2013-10-07   72  	PTR_LA	t8, __stack_chk_guard
1400eb65 Gregory Fong   2013-06-17   73  	LONG_L	t9, TASK_STACK_CANARY(a1)
1400eb65 Gregory Fong   2013-06-17   74  	LONG_S	t9, 0(t8)
1400eb65 Gregory Fong   2013-06-17   75  #endif
1400eb65 Gregory Fong   2013-06-17   76  
^1da177e Linus Torvalds 2005-04-16   77  	/*
^1da177e Linus Torvalds 2005-04-16   78  	 * The order of restoring the registers takes care of the race
^1da177e Linus Torvalds 2005-04-16   79  	 * updating $28, $29 and kernelsp without disabling ints.
^1da177e Linus Torvalds 2005-04-16   80  	 */
^1da177e Linus Torvalds 2005-04-16   81  	move	$28, a2
^1da177e Linus Torvalds 2005-04-16   82  	cpu_restore_nonscratch a1
^1da177e Linus Torvalds 2005-04-16   83  
3bd39664 Ralf Baechle   2007-07-11   84  	PTR_ADDU	t0, $28, _THREAD_SIZE - 32
^1da177e Linus Torvalds 2005-04-16   85  	set_saved_sp	t0, t1, t2
41c594ab Ralf Baechle   2006-04-05   86  #ifdef CONFIG_MIPS_MT_SMTC
41c594ab Ralf Baechle   2006-04-05   87  	/* Read-modify-writes of Status must be atomic on a VPE */
41c594ab Ralf Baechle   2006-04-05   88  	mfc0	t2, CP0_TCSTATUS
41c594ab Ralf Baechle   2006-04-05   89  	ori	t1, t2, TCSTATUS_IXMT
41c594ab Ralf Baechle   2006-04-05   90  	mtc0	t1, CP0_TCSTATUS
41c594ab Ralf Baechle   2006-04-05   91  	andi	t2, t2, TCSTATUS_IXMT
4277ff5e Ralf Baechle   2006-06-03   92  	_ehb
41c594ab Ralf Baechle   2006-04-05   93  	DMT	8				# dmt	t0
41c594ab Ralf Baechle   2006-04-05   94  	move	t1,ra
41c594ab Ralf Baechle   2006-04-05   95  	jal	mips_ihb
41c594ab Ralf Baechle   2006-04-05   96  	move	ra,t1
41c594ab Ralf Baechle   2006-04-05   97  #endif /* CONFIG_MIPS_MT_SMTC */
^1da177e Linus Torvalds 2005-04-16   98  	mfc0	t1, CP0_STATUS		/* Do we really need this? */
^1da177e Linus Torvalds 2005-04-16   99  	li	a3, 0xff01
^1da177e Linus Torvalds 2005-04-16  100  	and	t1, a3
^1da177e Linus Torvalds 2005-04-16  101  	LONG_L	a2, THREAD_STATUS(a1)
^1da177e Linus Torvalds 2005-04-16  102  	nor	a3, $0, a3
^1da177e Linus Torvalds 2005-04-16  103  	and	a2, a3
^1da177e Linus Torvalds 2005-04-16  104  	or	a2, t1
^1da177e Linus Torvalds 2005-04-16  105  	mtc0	a2, CP0_STATUS
41c594ab Ralf Baechle   2006-04-05  106  #ifdef CONFIG_MIPS_MT_SMTC
4277ff5e Ralf Baechle   2006-06-03  107  	_ehb
41c594ab Ralf Baechle   2006-04-05  108  	andi	t0, t0, VPECONTROL_TE
41c594ab Ralf Baechle   2006-04-05  109  	beqz	t0, 1f
41c594ab Ralf Baechle   2006-04-05  110  	emt
41c594ab Ralf Baechle   2006-04-05  111  1:
41c594ab Ralf Baechle   2006-04-05  112  	mfc0	t1, CP0_TCSTATUS
41c594ab Ralf Baechle   2006-04-05  113  	xori	t1, t1, TCSTATUS_IXMT
41c594ab Ralf Baechle   2006-04-05  114  	or	t1, t1, t2
41c594ab Ralf Baechle   2006-04-05  115  	mtc0	t1, CP0_TCSTATUS
4277ff5e Ralf Baechle   2006-06-03  116  	_ehb
41c594ab Ralf Baechle   2006-04-05  117  #endif /* CONFIG_MIPS_MT_SMTC */
^1da177e Linus Torvalds 2005-04-16  118  	move	v0, a0
^1da177e Linus Torvalds 2005-04-16  119  	jr	ra
^1da177e Linus Torvalds 2005-04-16  120  	END(resume)
^1da177e Linus Torvalds 2005-04-16  121  
^1da177e Linus Torvalds 2005-04-16  122  /*
^1da177e Linus Torvalds 2005-04-16  123   * Save a thread's fp context.
^1da177e Linus Torvalds 2005-04-16  124   */
^1da177e Linus Torvalds 2005-04-16  125  LEAF(_save_fp)
875d43e7 Ralf Baechle   2005-09-03  126  #ifdef CONFIG_64BIT
c138e12f Atsushi Nemoto 2006-05-23  127  	mfc0	t0, CP0_STATUS
^1da177e Linus Torvalds 2005-04-16  128  #endif
c138e12f Atsushi Nemoto 2006-05-23 @129  	fpu_save_double a0 t0 t1		# clobbers t1
^1da177e Linus Torvalds 2005-04-16  130  	jr	ra
^1da177e Linus Torvalds 2005-04-16  131  	END(_save_fp)
^1da177e Linus Torvalds 2005-04-16  132  
^1da177e Linus Torvalds 2005-04-16  133  /*
^1da177e Linus Torvalds 2005-04-16  134   * Restore a thread's fp context.
^1da177e Linus Torvalds 2005-04-16  135   */
^1da177e Linus Torvalds 2005-04-16  136  LEAF(_restore_fp)
c138e12f Atsushi Nemoto 2006-05-23  137  #ifdef CONFIG_64BIT
c138e12f Atsushi Nemoto 2006-05-23  138  	mfc0	t0, CP0_STATUS
c138e12f Atsushi Nemoto 2006-05-23  139  #endif
c138e12f Atsushi Nemoto 2006-05-23 @140  	fpu_restore_double a0 t0 t1		# clobbers t1
^1da177e Linus Torvalds 2005-04-16  141  	jr	ra
^1da177e Linus Torvalds 2005-04-16  142  	END(_restore_fp)
^1da177e Linus Torvalds 2005-04-16  143  
^1da177e Linus Torvalds 2005-04-16  144  /*
^1da177e Linus Torvalds 2005-04-16  145   * Load the FPU with signalling NANS.  This bit pattern we're using has
^1da177e Linus Torvalds 2005-04-16  146   * the property that no matter whether considered as single or as double
^1da177e Linus Torvalds 2005-04-16  147   * precision represents signaling NANS.
^1da177e Linus Torvalds 2005-04-16  148   *
^1da177e Linus Torvalds 2005-04-16  149   * We initialize fcr31 to rounding to nearest, no exceptions.
^1da177e Linus Torvalds 2005-04-16  150   */
^1da177e Linus Torvalds 2005-04-16  151  
^1da177e Linus Torvalds 2005-04-16  152  #define FPU_DEFAULT  0x00000000
^1da177e Linus Torvalds 2005-04-16  153  
^1da177e Linus Torvalds 2005-04-16  154  LEAF(_init_fpu)
41c594ab Ralf Baechle   2006-04-05  155  #ifdef CONFIG_MIPS_MT_SMTC
41c594ab Ralf Baechle   2006-04-05  156  	/* Rather than manipulate per-VPE Status, set per-TC bit in TCStatus */
41c594ab Ralf Baechle   2006-04-05  157  	mfc0	t0, CP0_TCSTATUS
41c594ab Ralf Baechle   2006-04-05  158  	/* Bit position is the same for Status, TCStatus */
41c594ab Ralf Baechle   2006-04-05  159  	li	t1, ST0_CU1
41c594ab Ralf Baechle   2006-04-05  160  	or	t0, t1
41c594ab Ralf Baechle   2006-04-05  161  	mtc0	t0, CP0_TCSTATUS
41c594ab Ralf Baechle   2006-04-05  162  #else /* Normal MIPS CU1 enable */
^1da177e Linus Torvalds 2005-04-16  163  	mfc0	t0, CP0_STATUS
^1da177e Linus Torvalds 2005-04-16  164  	li	t1, ST0_CU1
^1da177e Linus Torvalds 2005-04-16  165  	or	t0, t1
^1da177e Linus Torvalds 2005-04-16  166  	mtc0	t0, CP0_STATUS
41c594ab Ralf Baechle   2006-04-05  167  #endif /* CONFIG_MIPS_MT_SMTC */
f9509c84 Chris Dearman  2007-05-17  168  	enable_fpu_hazard
^1da177e Linus Torvalds 2005-04-16  169  
^1da177e Linus Torvalds 2005-04-16  170  	li	t1, FPU_DEFAULT
^1da177e Linus Torvalds 2005-04-16  171  	ctc1	t1, fcr31
^1da177e Linus Torvalds 2005-04-16  172  
^1da177e Linus Torvalds 2005-04-16  173  	li	t1, -1				# SNaN
^1da177e Linus Torvalds 2005-04-16  174  
875d43e7 Ralf Baechle   2005-09-03  175  #ifdef CONFIG_64BIT
^1da177e Linus Torvalds 2005-04-16  176  	sll	t0, t0, 5
^1da177e Linus Torvalds 2005-04-16  177  	bgez	t0, 1f				# 16 / 32 register mode?
^1da177e Linus Torvalds 2005-04-16  178  
^1da177e Linus Torvalds 2005-04-16  179  	dmtc1	t1, $f1
^1da177e Linus Torvalds 2005-04-16  180  	dmtc1	t1, $f3
^1da177e Linus Torvalds 2005-04-16  181  	dmtc1	t1, $f5
^1da177e Linus Torvalds 2005-04-16  182  	dmtc1	t1, $f7
^1da177e Linus Torvalds 2005-04-16  183  	dmtc1	t1, $f9
^1da177e Linus Torvalds 2005-04-16  184  	dmtc1	t1, $f11
^1da177e Linus Torvalds 2005-04-16  185  	dmtc1	t1, $f13
^1da177e Linus Torvalds 2005-04-16  186  	dmtc1	t1, $f15
^1da177e Linus Torvalds 2005-04-16  187  	dmtc1	t1, $f17
^1da177e Linus Torvalds 2005-04-16  188  	dmtc1	t1, $f19
^1da177e Linus Torvalds 2005-04-16  189  	dmtc1	t1, $f21
^1da177e Linus Torvalds 2005-04-16  190  	dmtc1	t1, $f23
^1da177e Linus Torvalds 2005-04-16  191  	dmtc1	t1, $f25
^1da177e Linus Torvalds 2005-04-16  192  	dmtc1	t1, $f27
^1da177e Linus Torvalds 2005-04-16  193  	dmtc1	t1, $f29
^1da177e Linus Torvalds 2005-04-16  194  	dmtc1	t1, $f31
^1da177e Linus Torvalds 2005-04-16  195  1:
^1da177e Linus Torvalds 2005-04-16  196  #endif
^1da177e Linus Torvalds 2005-04-16  197  
^1da177e Linus Torvalds 2005-04-16  198  #ifdef CONFIG_CPU_MIPS32
^1da177e Linus Torvalds 2005-04-16  199  	mtc1	t1, $f0
^1da177e Linus Torvalds 2005-04-16  200  	mtc1	t1, $f1
^1da177e Linus Torvalds 2005-04-16  201  	mtc1	t1, $f2
^1da177e Linus Torvalds 2005-04-16  202  	mtc1	t1, $f3
^1da177e Linus Torvalds 2005-04-16  203  	mtc1	t1, $f4
^1da177e Linus Torvalds 2005-04-16  204  	mtc1	t1, $f5
^1da177e Linus Torvalds 2005-04-16  205  	mtc1	t1, $f6
^1da177e Linus Torvalds 2005-04-16  206  	mtc1	t1, $f7
^1da177e Linus Torvalds 2005-04-16  207  	mtc1	t1, $f8
^1da177e Linus Torvalds 2005-04-16  208  	mtc1	t1, $f9
^1da177e Linus Torvalds 2005-04-16  209  	mtc1	t1, $f10
^1da177e Linus Torvalds 2005-04-16  210  	mtc1	t1, $f11
^1da177e Linus Torvalds 2005-04-16  211  	mtc1	t1, $f12
^1da177e Linus Torvalds 2005-04-16  212  	mtc1	t1, $f13
^1da177e Linus Torvalds 2005-04-16  213  	mtc1	t1, $f14
^1da177e Linus Torvalds 2005-04-16  214  	mtc1	t1, $f15
^1da177e Linus Torvalds 2005-04-16  215  	mtc1	t1, $f16
^1da177e Linus Torvalds 2005-04-16  216  	mtc1	t1, $f17
^1da177e Linus Torvalds 2005-04-16  217  	mtc1	t1, $f18
^1da177e Linus Torvalds 2005-04-16  218  	mtc1	t1, $f19
^1da177e Linus Torvalds 2005-04-16  219  	mtc1	t1, $f20
^1da177e Linus Torvalds 2005-04-16  220  	mtc1	t1, $f21
^1da177e Linus Torvalds 2005-04-16  221  	mtc1	t1, $f22
^1da177e Linus Torvalds 2005-04-16  222  	mtc1	t1, $f23
^1da177e Linus Torvalds 2005-04-16  223  	mtc1	t1, $f24
^1da177e Linus Torvalds 2005-04-16  224  	mtc1	t1, $f25
^1da177e Linus Torvalds 2005-04-16  225  	mtc1	t1, $f26
^1da177e Linus Torvalds 2005-04-16  226  	mtc1	t1, $f27
^1da177e Linus Torvalds 2005-04-16  227  	mtc1	t1, $f28
^1da177e Linus Torvalds 2005-04-16  228  	mtc1	t1, $f29
^1da177e Linus Torvalds 2005-04-16  229  	mtc1	t1, $f30
^1da177e Linus Torvalds 2005-04-16  230  	mtc1	t1, $f31
^1da177e Linus Torvalds 2005-04-16  231  #else
^1da177e Linus Torvalds 2005-04-16  232  	.set	mips3
^1da177e Linus Torvalds 2005-04-16 @233  	dmtc1	t1, $f0
^1da177e Linus Torvalds 2005-04-16 @234  	dmtc1	t1, $f2
^1da177e Linus Torvalds 2005-04-16 @235  	dmtc1	t1, $f4
^1da177e Linus Torvalds 2005-04-16 @236  	dmtc1	t1, $f6
^1da177e Linus Torvalds 2005-04-16 @237  	dmtc1	t1, $f8
^1da177e Linus Torvalds 2005-04-16 @238  	dmtc1	t1, $f10
^1da177e Linus Torvalds 2005-04-16 @239  	dmtc1	t1, $f12
^1da177e Linus Torvalds 2005-04-16 @240  	dmtc1	t1, $f14
^1da177e Linus Torvalds 2005-04-16 @241  	dmtc1	t1, $f16
^1da177e Linus Torvalds 2005-04-16 @242  	dmtc1	t1, $f18
^1da177e Linus Torvalds 2005-04-16 @243  	dmtc1	t1, $f20
^1da177e Linus Torvalds 2005-04-16 @244  	dmtc1	t1, $f22
^1da177e Linus Torvalds 2005-04-16 @245  	dmtc1	t1, $f24
^1da177e Linus Torvalds 2005-04-16 @246  	dmtc1	t1, $f26
^1da177e Linus Torvalds 2005-04-16 @247  	dmtc1	t1, $f28
^1da177e Linus Torvalds 2005-04-16 @248  	dmtc1	t1, $f30
^1da177e Linus Torvalds 2005-04-16  249  #endif
^1da177e Linus Torvalds 2005-04-16  250  	jr	ra
^1da177e Linus Torvalds 2005-04-16  251  	END(_init_fpu)

:::::: The code at line 67 was first introduced by commit
:::::: c138e12f3a2e0421a4c8edf02587d2d394418679 [MIPS] Fix fpu_save_double on 64-bit.

:::::: TO: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
:::::: CC: Ralf Baechle <ralf@linux-mips.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--cNdxnHkX5QqsyA0e
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--cNdxnHkX5QqsyA0e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
