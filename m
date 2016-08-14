Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 133026B0005
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 18:56:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so89109597pfx.0
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 15:56:32 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 141si23131460pfw.92.2016.08.14.15.56.30
        for <linux-mm@kvack.org>;
        Sun, 14 Aug 2016 15:56:31 -0700 (PDT)
Date: Mon, 15 Aug 2016 06:55:46 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-stable-rc:linux-3.14.y 1941/4884]
 arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this
 processor: r4600 (mips3) `sdc1 $f0,648($4)'
Message-ID: <201608150641.2uN3AfDn%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sasha,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-3.14.y
head:   43ef7e3ec8016449b3b0afdeaee89053687d1680
commit: 017ff97daa4a7892181a4dd315c657108419da0c [1941/4884] kernel: add support for gcc 5
config: mips-allnoconfig (attached as .config)
compiler: mips-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 017ff97daa4a7892181a4dd315c657108419da0c
        # save the attached .config to linux build tree
        make.cross ARCH=mips 

All errors (new ones prefixed by >>):

   arch/mips/kernel/r4k_switch.S: Assembler messages:
>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f0,648($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f2,664($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f4,680($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f6,696($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f8,712($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f10,728($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f12,744($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f14,760($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f16,776($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f18,792($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f20,808($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f22,824($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f24,840($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f26,856($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f28,872($4)'
   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f30,888($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f0,648($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f2,664($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f4,680($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f6,696($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f8,712($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f10,728($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f12,744($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f14,760($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f16,776($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f18,792($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f20,808($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f22,824($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f24,840($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f26,856($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f28,872($4)'
   arch/mips/kernel/r4k_switch.S:129: Error: opcode not supported on this processor: r4600 (mips3) `sdc1 $f30,888($4)'
>> arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f0,648($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f2,664($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f4,680($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f6,696($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f8,712($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f10,728($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f12,744($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f14,760($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f16,776($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f18,792($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f20,808($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f22,824($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f24,840($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f26,856($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f28,872($4)'
   arch/mips/kernel/r4k_switch.S:140: Error: opcode not supported on this processor: r4600 (mips3) `ldc1 $f30,888($4)'
>> arch/mips/kernel/r4k_switch.S:274: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f0'
>> arch/mips/kernel/r4k_switch.S:275: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f2'
>> arch/mips/kernel/r4k_switch.S:276: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f4'
>> arch/mips/kernel/r4k_switch.S:277: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f6'
>> arch/mips/kernel/r4k_switch.S:278: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f8'
>> arch/mips/kernel/r4k_switch.S:279: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f10'
>> arch/mips/kernel/r4k_switch.S:280: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f12'
>> arch/mips/kernel/r4k_switch.S:281: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f14'
>> arch/mips/kernel/r4k_switch.S:282: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f16'
>> arch/mips/kernel/r4k_switch.S:283: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f18'
>> arch/mips/kernel/r4k_switch.S:284: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f20'
>> arch/mips/kernel/r4k_switch.S:285: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f22'
>> arch/mips/kernel/r4k_switch.S:286: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f24'
>> arch/mips/kernel/r4k_switch.S:287: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f26'
>> arch/mips/kernel/r4k_switch.S:288: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f28'
>> arch/mips/kernel/r4k_switch.S:289: Error: opcode not supported on this processor: mips3 (mips3) `dmtc1 $9,$f30'

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
597ce172 Paul Burton    2013-11-22  126  #if defined(CONFIG_64BIT) || defined(CONFIG_CPU_MIPS32_R2)
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
597ce172 Paul Burton    2013-11-22  137  #if defined(CONFIG_64BIT) || defined(CONFIG_CPU_MIPS32_R2)
c138e12f Atsushi Nemoto 2006-05-23  138  	mfc0	t0, CP0_STATUS
c138e12f Atsushi Nemoto 2006-05-23  139  #endif
c138e12f Atsushi Nemoto 2006-05-23 @140  	fpu_restore_double a0 t0 t1		# clobbers t1
^1da177e Linus Torvalds 2005-04-16  141  	jr	ra
^1da177e Linus Torvalds 2005-04-16  142  	END(_restore_fp)
^1da177e Linus Torvalds 2005-04-16  143  

:::::: The code at line 67 was first introduced by commit
:::::: c138e12f3a2e0421a4c8edf02587d2d394418679 [MIPS] Fix fpu_save_double on 64-bit.

:::::: TO: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
:::::: CC: Ralf Baechle <ralf@linux-mips.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--zhXaljGHf11kAtnf
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
7j9SkvhTEayBVCTj973/88X/ABCXu7tLRAAA

--zhXaljGHf11kAtnf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
