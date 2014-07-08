Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B42EC6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 09:35:50 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so7251770pad.26
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 06:35:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bs7si6067151pdb.506.2014.07.08.06.35.48
        for <linux-mm@kvack.org>;
        Tue, 08 Jul 2014 06:35:49 -0700 (PDT)
Date: Tue, 08 Jul 2014 21:35:40 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: include/linux/atmel-mci.h:26: error: expected
 specifier-qualifier-list before 'bool'
Message-ID: <53bbf3ac.VNqkKhP7FO+SIDc8%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   448bfad8a185876ce8de484a921d49769972cad7
commit: 2635d1ba711560d521f6218c585a3e0401f566e1 atmel-mci: change use of dma slave interface
date:   4 years, 7 months ago
config: make ARCH=avr32 hammerhead_defconfig

All error/warnings:

   In file included from arch/avr32/boards/hammerhead/setup.c:10:
>> include/linux/atmel-mci.h:26: error: expected specifier-qualifier-list before 'bool'

vim +/bool +26 include/linux/atmel-mci.h

965ebf33 arch/avr32/include/asm/atmel-mci.h Haavard Skinnemoen 2008-09-17  20   * But in most cases, it should work just fine.
6b918657 arch/avr32/include/asm/atmel-mci.h Haavard Skinnemoen 2008-08-07  21   */
6b918657 arch/avr32/include/asm/atmel-mci.h Haavard Skinnemoen 2008-08-07  22  struct mci_slot_pdata {
6b918657 arch/avr32/include/asm/atmel-mci.h Haavard Skinnemoen 2008-08-07  23  	unsigned int		bus_width;
7d2be074 include/asm-avr32/atmel-mci.h      Haavard Skinnemoen 2008-06-30  24  	int			detect_pin;
7d2be074 include/asm-avr32/atmel-mci.h      Haavard Skinnemoen 2008-06-30  25  	int			wp_pin;
1c1452be include/linux/atmel-mci.h          Jonas Larsson      2009-03-31 @26  	bool			detect_is_active_high;
7d2be074 include/asm-avr32/atmel-mci.h      Haavard Skinnemoen 2008-06-30  27  };
7d2be074 include/asm-avr32/atmel-mci.h      Haavard Skinnemoen 2008-06-30  28  
6b918657 arch/avr32/include/asm/atmel-mci.h Haavard Skinnemoen 2008-08-07  29  /**

:::::: The code at line 26 was first introduced by commit
:::::: 1c1452be2e9ae282a7316c3b23987811bd7acda6 atmel-mci: Add support for inverted detect pin

:::::: TO: Jonas Larsson <jonas.larsson@martinsson.se>
:::::: CC: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
