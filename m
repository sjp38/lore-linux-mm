Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A3F696B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 08:36:31 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 5so340017797ioy.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 05:36:31 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fj3si755925pab.156.2016.06.20.05.36.30
        for <linux-mm@kvack.org>;
        Mon, 20 Jun 2016 05:36:30 -0700 (PDT)
Date: Mon, 20 Jun 2016 20:39:57 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-stable-rc:linux-3.14.y 1941/4754]
 arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this
 processor: r4600 (mips3) `sdc1 $f0,648($4)'
Message-ID: <201606202053.5cdtaMIn%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="azLHFNyN32YCQGCU"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-3.14.y
head:   96f343e0621a0d5afa9c2a34e2aee69f33b6eb5c
commit: 017ff97daa4a7892181a4dd315c657108419da0c [1941/4754] kernel: add support for gcc 5
config: mips-allnoconfig (attached as .config)
compiler: mips-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
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

--azLHFNyN32YCQGCU
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICLvjZ1cAAy5jb25maWcAjFtLc9u4st7Pr2Bl7uKcqjMTW5YfqVtegCAoIiIJBgD18Ial
kZWJKrbkK8kzk39/GwApgSTAnEUcG914sNGPrxvAr7/8GqD30/51ddquVy8vP4I/N7vNYXXa
PAdfty+b/w0iFuRMBiSi8ndgTre7938+vm7fjsHN79fj30ejYLo57DYvAd7vvm7/fIe+2/3u
l19/wSyP6aTKaCEef/wCDb8G2Wr9bbvbBMfNy2Zds/0aWIwVSnFCsmWwPQa7/QkYTxcGxO/d
7TK5/+SkhDgb3y8WPtrdjYeml4JZiFLppiOcVBHBQiJJWe7n+YyengaoT+P78ZWTnqJc0i8e
kkADy0oZyydiaFENx7X/2zP4cuQnC4KiGyc5Jxg68ymhufCvYMbH1x7R54uiEjIcjdxyOZNv
neQig+lF4aRxlNJ8apNqgpjQihajEWjpmblucytcTXwYIN6M3EQaLiWpME9oTgY5EM9I+pMx
2PAYP2UQc5hliCGlUqZElHxwFJJLJtzaUrOEdOIdJKeVZxFaVeTi5pPPSg197KXTKWeSTise
3nr2A6MZLbOKYUlYXgmG3UqXZtUi5VXIEI8GOIoBjtqxVZOCsormEeUES4cy8rkgWTUhOeEU
V6Kgecrw1FZNxOGzEyQqmrLJqCo9n9Zluxs7ZmvmSeaEThIJ03QIGIwm5Aj2MCIpWl4YBHxO
VLGMyirmKCNVwWguCb9wxHO1hsvfmMxkxcdTq0VwXLe0lx1lqEJRxCtZ3Y1D6pKTYslZjllC
OCjgZdCcwLoUNUPKVcDSLzT6MLr9ZM9WOzvsNcccNosVjLuW0MiICqQm7AuvJlSiLNQQVcjZ
lOTWcmo6KqgllKJU9lIR0BFkMYulaAYSbYb21yTlhFQyDRtmx8Ip/6Kmscaeg6xAL0WBsCUu
5cq0BuXRMmKTPiFB6ajfKgj50m+dR59u+q1PSjsdMz5cja2RIxKjMpWaXCAuqYq6XU27sTqE
jMmKpLHdpqWTXoNKg+pWIqGxrO4HyY/3Lb0ERJALlhKHRBW14CwDY2mwDgi4hXOs7eXjxdWV
vXG68fbq6soVnZZCi8Tu6CKp7h5tuRmBDVVTwnOSeli0mfVY1MA/GaXF8l+MotSzQBNyxoQ1
ejz9eNtcpKTnsiXUcwNnynQG7rIkwqXoaiKIQU+kGk9De7gL4fpuGrqhxJnlbtxmabSOcUzA
eSyqJ4izjEfg/K6vLxoIkQC8pNImy+IBZhh5dAiqrXEbUZkVyoLbVPCTVWwbbdNoFLbFb9ya
rCLwMGFKop6DLRLY/J94WDW+Nudlbnlx3T1OkcwgTJFcDW8ZomlvN4APjUBOwA4e+UJK0Ey3
hnV8czXXXe1uJj5QkB+I1+p+/j49gLJ/NSPNY6YH8SgHrG8iKrKQ4Ey1mBrbKAD6VIXUiwBB
iMfxWSwsAy/ZdkAZnXBUN10U6L+QsdIcHQLUQh6vmuYZhWghWRWWwh5xKjJXJKydY6YCXkZz
Pefj+OrT3XnJnAmhhMX4ErIlCQrTiZcF4Xq/p1nLLaUE5Vq9nBYSc5ZLFTrc0CpzQ8KnsHQj
pCcBWUfqgWDJUzV2422gXF+5kwVFaqP0C2F02/LAuuVuYAL/DFcjF7JqeVfElV9Mniw1f3qE
FZxVkROSFcpSctJSobp9xtIyl4i78+Kay+0dyYK4JYo5Eon2Na7VE6z0vAcu2M0InNDdeABc
KJOJSNFwWDYFejeVHBBGnwY63HSnQj5++Piy/ePj6/75/WVz/Pg/Za4AJiegjoJ8/H2tCw0f
bDQzZ9zyIWFJ00hS6AOWrTwUIHs9mw44E13geFFrfn+7hBwDziqVBmSWv6E57BzJZ7CHanGA
dx9vRm3DUpKi4AY/fLCka9oq6Q5MICSUzggXymd8+OBqrlApWR8CJUxIJY7HD//a7Xebf5/7
KkNsZbBLMaOFe+/jBOVRG8ho0YAog+P7H8cfx9Pm9SKaM54FSQPKCS2Pb5NEwuaW4KBFh8io
kgknKKL5pN8PK3UhM0DwYpBo9tTBkjFRlUVkYL7+CLl93RyOru8AawVHR1lEsS0pwPhAoR2B
tMlu64ecCdRSVErXuOiJEzzqR7k6fg9OsKRgtXsOjqfV6Ris1uv9++603f15WZukJtJUCCwP
jN1I61KtEpESPSagb8Ahe3NxXAai/8kwzrICmsurqC7OQgkulbGmqdLizFNJkjCI5tQW7WSh
U/OLU/+VlcY1zL62cDaecFYW7toRBCI81Xmmkrpk3BXWlXHoPMZSqBIUKG+F0lJAxGuXqBrp
0KjDa1JdZY56be4yxlLEAowUZItBF90RjqsU2l2MTKfQeaa9jaeAgHHFClA0hUjBrjQ0dccd
LC3wjSCmwLAAgVrfRBZgCe6QYUbQ/4EOOKaYQrNYZpZ8Cw570nLAlqlDGgaKxC2nEYIbr+Iy
tZYZl5IsrD4Fs6mCTnKUxpb9a4uzG7SbsBtE0kKiiLLW92chiaL2PtkAEqQTV12/pBtBc6qZ
QSqdFKbYHL7uD6+r3XoTkL82O7B0BDaPla2DR7Jr3dbwjhVARqNplfYE4Fmsr0rLEDSlJWCN
SFV1oYWDRYpcWYsaoO0MWExT8DY+STDD0cIln1WGAuN7KpS6n8kFUQpbp6wHK9flm2Oqo4r1
maaVE+kk6BxA+52EsW7uoAsqUnJHPIHArt18HZBcHQvale5lxstXd9KROYK9glirahNKO+q4
3h4C7FcjIPgiSTA4rxbS7hJd+ViXpwcX+xycTMoUuSuvfW4hAdF7FQF+BxuVWvDTVjA3ORuL
jDREQTCNqV35S1WaE0K3OWRt58x/gtnstz9Wx81z8N1Y0Nth/3X70oqLeuxzZgxb1K/4KU1X
id6lBbKnTDkUW3O009EpBuRZF1TLojIlLsXs5KVpGKHYGq122KFoh+lLc0rddYWLq5dkwqn0
BwScRWCYxGgV70X8YnU4bVVxKZA/3jZt99LUyCAXnEEK5/RzmYgAOznKaZ4qG4nbzQYxskCs
v20UUNcergn9zATNnDEbS9etERif+rI+BcdfbHE2oLfpMJD9enqqBQz0qud9/LD++n+XhCLX
Yle196rU5XcFZu2UQNOVC6npQzRn3zlsPPF1tont3jGAriddY9fCD9+Pwf5NqcAx+FeB6X+C
AmeYov8EhAr4qX9I/G/Lmua6pKPIrWhI2+c3jYZkVrlJ1c5vWpED485hh14U+Wezfj+t/njZ
6APkQIfEk6UbylYzXZ3tuNELoeKQnzANdQpqV8kARpjyWLOBijkBYbeCZD2QwJwWrSqi8eWs
dAOfultGBXa5X5hbTW1hEA6bbKDJ2acV+783hwAwwOrPzStAgGZ/Lp9vzmVoSHiuS0ZVATkk
bZXRjBstwZHmkYNcU3oNlnpYKcp5IhfWzcB5EtLKG6FNQV3d7jljhYA3JUo73TAdGLjKYDJn
1S3rTKbDrXOcOWSbbA44ncQQTqgCRPW2u3RVlSdUIQ++NjXwsJXjkX7KFG3+2gJUiw7bv4zz
upQHtuu6OWDd/SsNNEtIqopmALySVuIPrl1mReyKKBBt8wilzHZ8kC/o4WLKMwiOpJvnxnPI
lZR6W00NK7inbqkdBMDRmcOqLJzHMZmPWX2nXFAlS2icUcHcgOGcc0OWCp9JMXHvvz7ySmD+
SOV4sSN0Kcf1rKXfCluZdMUpbQ2ZOp6sobnGWXX9yA55noJUHXBdYTqHHET9MRioMZsPJcIN
W9qJNEbFeBgFz9ujcofPwR+b9er9uAlUIl+BiuwPAVWKabqoo6LNsy2PZmiO3AfkOOIsq4qp
xNHMnTQ2IyR9P51tj2vXJgiSgwIIVYi7SWdXI/fA4AmzpQpO7rNnmRHIIIW7+kRyAISi5Orq
APerkfB+9qi70ybwEHUCFxzf3972h5P9SYZSfbrBi7teN7n5Z3UM6O54Ory/6qTt+G11gN06
HVa7oxoqeFF3lmAX19s39WvjKdALpHWrIC4mCELd4fVv6BY87//evexXz4GpXja8FFLAlyCj
OEj2x1PtXPpEvDo8X4h21KJRC+rTqF+9E1jQekctKTTSBKJCu/YgHNHI5EruDVDj+QjKyv1E
0OruZRtLOTw3i/o6Sndv7yfvJ9G8KFs+QDdUcayOOtJOutlhUvUFMIwBDqFh9zTzHG8YpgxJ
ThddJr328rg5vKia31Zl/19XxszavRk4Y+OanO1VIVC58FIB3xCSV4tHdQQxzLN8vL976C7+
M1sOi4DMfkbvhG5r03rBtdVzSpb6gPTybU0LqMc0bGnpmZJOgeI55ahZcjKXHj995mGAlRSY
c6vHmU1INkdzT73uwlXmP13UQnZY+ltlHSWqP2HjR46mCqWFcLWnbALwZ1QULqJY5qiQFDt7
4iUgEOEk6TxfV1tbx0BnOlF3FAlO3MZ8mR7gDUmpOxRYs7ESJ1PPGb9hg2hBkbviZBhQUaRE
DzTAFOLs9tP9eIBjJhaLBfI4KbOSRqSAptxZ/tnChCrsD7Do8yn3V9cM6nuMGQ85ok7Soi0x
gWiigxL9yALlOy07VMJknZSjDbI6HPrP7sUc0wg/O0d9ujmlodFjC1uodo7m7sihqSgFDI+U
TgwwATUrPZdz62HUjRzPGBOUESeEwBD5V4DCDhYwapI9aV1+m1nfis2lIGUuuUh1piVszobB
1XbOvi7p+YX7vFzgvxBUlhq5y7VlThefHqpCLlulfvDhhRSVkhcF+wCFUYkIdha9UjJBeNkM
0Ws0BenH0e1dW9yQceUsN/mN5/iiPvh138CFJU5Ntd4AGUjAVi/B8zl2dCd7GN1e9TYv3+9+
04Sj6a6hmwMN1mPoqzj6+plXi4BLYJwvPEc+hgNSTUixIa/zXLU1XLVWf5ZoUiLfwUuL9ads
3O1Sa3Is0iotvIPQIlM37dQpsKvWDPpmSjCtWkLTaNJrymDL3OdcN5/u3A4WTL+KOJ0Rd4Yp
Mfwr3IPSked7CzdITdrg1VRnCuHSiKLon92qtvopxF6fJje9DFUWwfplv/7uHE4W1fXtw4M5
v+7nKTtdHCuSpSoRK4QIaFldYFA3hrRowZCyQtn4aQ/dNsHp2yZYPT/rYi8otp74+Hu3pKRr
9CXAlsxcMk7svZu7L/ub+oq6jpF67pZoBjRzHt3Ms/aNJ91QzajbAxiqLvdUOKF9xJyvTmDw
brM3OWl8f/1wdRt79P7C8zCKfVZtmKh88FztrxkytLj+NMySY3l3f+9+h3DmkbiSCeEQnqWn
qtKwFvjh/ubOfc3I5hn7HiXUPCITeHyfufe7zRTe/OQTBU5u7xaLofJHwzqT16Pr4UnnDzd3
o/tkePsME/FwaVl6MOAcSZxEzBUZhQjtOqoJMvvddn0MxPZlu97vgnC1/v4G+dqmpXfCdYQK
CBL1hgsPkPSv96/B8W2z3n7drgOUhahVzenciDNVmPeX0/br+07fEm4yXYcFZHGkK9BuUKqI
nInKc9UrkapkJih2v9lR3ackK1K33SqyyG6v3JuLwsXt1dXw2tRVAt+DJCBLWqHs5uZ2UUmB
UeTJFBRjRpk7rOhjTp+FZSSiyHVjzdR7D6u3b0oTHJ488rxMmU2QflngJtKIsIqVUuFyaJOc
uRU2dqcOZLHMYS/1MO6iHuRlqYbqKY6834X3u+P+RdetQK9/1ErVr6LAtzhBJ2A+/SQm1gcp
LE3VtG7TnaiCz1w/ccDeK/KmYuiYSQCm7Jd+EogivbVCY/twI/LlEmVCnXc7aNSUsc9+QNkr
RFXV4blbrVD8aKyy3M68FcK8XHhm0Hlor0PJCXJdp1HEkKRTat8YgDYMvo4vu20U/uo2nnP4
1oQgmwnLORVuNVUsJIN46fa0mpwS8PyeJZOnKVl254Qmf/6tGZb+1ZRY1TE8Lgzoc0DGzI3F
9b4uuf81pmKg4Fz8s8s5zQEQe752CuEJEJnsAB6gpFhjJO+4KcnZjAGsdReBNAt8dlfHmjbf
/ig6LzOIQAWKRkNck0/jqyH6PCEkHdSDDMG26MqH5wMyqsIPuIq2YgJmgFSmryU6FR3WE/Al
xO1tFLVAuUICKfMkm5qHSJQuc/fTQM0ApgQO1E/nFFCglywQHVqiQJkoczcK1fSCkMhbI9cc
Uu0LuCpPpVLzlHmRln76RJWNIPK7i1l6hAxSxM9sOTiMpDN3KNJEVgjiufGo6QmHrCSDiDlg
JQuaZ/4pnghngwt8WkbgkAds38DLKildgK4EeMgSTOv3rr2nd4reu7KuGs9vLBPcCkydqqA5
D4A2XZJ4bp83q/bi24+jen4fpKsfqvjUx39qNkgPnd+Xs0LTF5hQd7m+VkbFNfKNYvHc+HjU
LBMUTTwFyyzzYDeIM94yKCAH8JGRe2/NtUEa0rRzUaoBfoBszZu7CxaU6uI48pz+RBkaOrpG
5SKiovBd0y09+FO/1zF1jX4lYbY9ALh3barqBol61oG19fHs+rA/7r+eguTH2+bw2yz4831z
dBe0JPjnvH8Qcy7/irftThcrevgGp1P1Bre523NpVW91+61hGvXvAWWIpiFzYSEKaWNpWY65
qL553Z82b4f92pnpS32TkGQVV6fkvW/ib6/HP10d9U2SWcyJ+0SaLKQ3BdHvotw1J89+F3NP
jaoAjKxebXmyFEHOGUHqcYZx1v9oZY723f4zc3Mjw2evqqBUpxMZLWg/p2j4FILB+v2IHj5u
TrOjvqDP109Abq5zz1hd+jJLbfWDHRhVsVsyQLsZoI19NE4A3fJY+Oif/aSFnzSJhXeloRyY
LqfpQFfoVzBBF+DUXGmAumOtH0+1rtbGImeSxhbij7oN1DToiz22XcbIEJyL+VIyzzG8pmDp
TlnVzbBYePcjVodjcd8F4tX6W/uWSSx67woNOfqNs+yjus+iFMmhR1SwT3d3V74llFHsWkHE
xMcYyY+59I1rrsN6Rp1BX++uy55GGKs9bt6f9/oS5GW6xuDMDaDORXxcTbt1FJvYfdqhG/Uz
ZQDa1Nwob9yoeo5ij967k3ZBRyWE8zTUAzkZzH+9b2zERgXWugtTSpK1JkWR31ZQ7KclgyQF
BL3mSfxdQz9poBdkSB4K5ijzkMSXEonEp0sDriejOTiInxArdZ9z1sBUJyvLBkRY+Glf8sV4
kHrnp/KhSYvec62LsJZi5rVm/4jxaMARp31zrB/pfFutv7cf3umDScq/mLfgHbTydtjuTt/1
Kc3z6wagx+U+r2W56vVT5bnwen6eDUBW2SooVEpmJH0cN3W61zdwEb/pN4LgJtffj3q6tWk/
9G8Qm1f3FQTh3HpxZl0CNfQMsi7zZM6+QK5e0qqe5tKQhbs4LSokskq97HLvRa7uFCl6yFI3
iznccfqJ+pL2eUGdPuL/C7manuZhGPxXdgQJTS9w4Zql7QjrmqpNQeNSAaomDnxorBL8+9d2
srZJHbhVtZM0VuzGiZ8nJUg9hpMtnuPzDoDnELheImWHtitbEzvfUMO+8/CzSLrnfr+3K2Cc
/YCqamPXHKiBZ75RDJMbnErPxMTk9r0D3yO+L4Qd2fkjEkdD/pDlBKJ1BcrwrYscdu79p10U
t0/v+wDpUYBJwHBal9ynefL2XuRNOtIMWCGuW90YeE0d43CjlRZnXy55+LpYvPXH7ruDh+74
slwuz08pLAJJebtaQBTCRB09UMx6WVPYBUDuWAU2GqTrSpS3f+hYh95SqQLhr0OD7wqxhXln
pBj24rUG19JViBNzwEg7Dk0rxKdJ19D24gEGJOzuJjFmjGYzGK21LMKEIS4YSP0C2wqjYRYI
xU/zLISZj/99EJBzF2tX9M17LultQNGwmRxVpbeJRsYmz3mnmLnYsULJA6xGYN1mnXgp/An4
tNJ67sd199IfXo8/XCTepLvIDzmVDWKt4IPTmjIxMImM1VdY3V+FbIwbaIqG0YScBgJf6vMF
VLvSRK57VCEgdNBfJpuZI399PjxBXDt89LBCOg9nYxBcUNUMXL+UCrPzKbHKgOT3cLISaY+k
MrypQHrJk2ZgO3P5L1H8qTKKlWlalnfGUTlNla+v2GXuK+RKpqvdDdPUSviSFKciqofYhZ7V
iPEPgZS/RM/VilrG6Dckz2diS2wiEx7T10fkn/xF1K7kHet0dUuFO9OQVTuOM/8dS2l2ijpB
5SDqDwEJR1cZJbu4T/UyAliP8TyjShQ/pSThD0vwAK0RuXqcXfz8B7Z3NOzYVAAA

--azLHFNyN32YCQGCU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
