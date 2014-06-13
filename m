Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 02DE26B0031
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:57:28 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so1576596pde.28
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 18:57:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id zz3si2967531pac.115.2014.06.12.18.57.27
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 18:57:28 -0700 (PDT)
Date: Fri, 13 Jun 2014 09:56:57 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 83/178] binfmt_elf.c:undefined reference to
 `__compiletime_assert_505'
Message-ID: <539a5a69.p/SWeI0irZZ7D9/s%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a621774e0e7bbd9e8a024230af4704cc489bd40e
commit: d6dc10868bc1439159231b2353dbbfc635a0c104 [83/178] mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code
config: make ARCH=avr32 atngw100_defconfig

All error/warnings:

   fs/built-in.o: In function `load_elf_binary':
>> binfmt_elf.c:(.text+0x2ca84): undefined reference to `__compiletime_assert_505'
>> binfmt_elf.c:(.text+0x2ca88): undefined reference to `__compiletime_assert_506'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
