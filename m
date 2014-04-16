Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 52B2C6B0083
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:22:09 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so10723652pab.27
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 01:22:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id iw3si12265102pac.301.2014.04.16.01.22.03
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 01:22:03 -0700 (PDT)
Date: Wed, 16 Apr 2014 15:57:58 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 103/113] arch/powerpc/platforms/52xx/efika.c:210:2:
 error: 'ISA_DMA_THRESHOLD' undeclared
Message-ID: <534e3806.dEDbrOl+B+miaF+8%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   2db08cc65391d73dc8cbcaefdb55c42a774d9e1a
commit: ff35bd54456e18878c361a8a2deeb41c9688458f [103/113] lib/scatterlist: make ARCH_HAS_SG_CHAIN an actual Kconfig
config: make ARCH=powerpc ppc6xx_defconfig

All error/warnings:

   arch/powerpc/platforms/52xx/efika.c: In function 'efika_probe':
>> arch/powerpc/platforms/52xx/efika.c:210:2: error: 'ISA_DMA_THRESHOLD' undeclared (first use in this function)
     ISA_DMA_THRESHOLD = ~0L;
     ^
   arch/powerpc/platforms/52xx/efika.c:210:2: note: each undeclared identifier is reported only once for each function it appears in
>> arch/powerpc/platforms/52xx/efika.c:211:2: error: 'DMA_MODE_READ' undeclared (first use in this function)
     DMA_MODE_READ = 0x44;
     ^
>> arch/powerpc/platforms/52xx/efika.c:212:2: error: 'DMA_MODE_WRITE' undeclared (first use in this function)
     DMA_MODE_WRITE = 0x48;
     ^

vim +/ISA_DMA_THRESHOLD +210 arch/powerpc/platforms/52xx/efika.c

9724b86f Sylvain Munaut 2007-02-12  204  
9724b86f Sylvain Munaut 2007-02-12  205  	if (model == NULL)
9724b86f Sylvain Munaut 2007-02-12  206  		return 0;
9724b86f Sylvain Munaut 2007-02-12  207  	if (strcmp(model, "EFIKA5K2"))
9724b86f Sylvain Munaut 2007-02-12  208  		return 0;
9724b86f Sylvain Munaut 2007-02-12  209  
9724b86f Sylvain Munaut 2007-02-12 @210  	ISA_DMA_THRESHOLD = ~0L;
9724b86f Sylvain Munaut 2007-02-12 @211  	DMA_MODE_READ = 0x44;
9724b86f Sylvain Munaut 2007-02-12 @212  	DMA_MODE_WRITE = 0x48;
9724b86f Sylvain Munaut 2007-02-12  213  
9724b86f Sylvain Munaut 2007-02-12  214  	return 1;
9724b86f Sylvain Munaut 2007-02-12  215  }

:::::: The code at line 210 was first introduced by commit
:::::: 9724b86f0706ca9b552d82e013cb0c208b4f5529 [POWERPC] Small cleanup of EFIKA platform

:::::: TO: Sylvain Munaut <tnt@246tNt.com>
:::::: CC: Paul Mackerras <paulus@samba.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
