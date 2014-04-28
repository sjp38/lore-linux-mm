Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6786B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 04:14:39 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y13so4556013pdi.28
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 01:14:38 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id pn4si9885905pac.462.2014.04.28.01.14.37
        for <linux-mm@kvack.org>;
        Mon, 28 Apr 2014 01:14:37 -0700 (PDT)
Date: Mon, 28 Apr 2014 16:11:17 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 249/284] clkdev.c:undefined reference to
 `rcu_sysrq_start'
Message-ID: <535e0d25.iXuzvLefda9Codvs%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   5bd4e10b96ce20271688aa31d8bd739441249152
commit: 8429721cf61b29efef3b66331ac134457d729462 [249/284] sysrq,rcu: suppress RCU stall warnings while sysrq runs
config: make ARCH=arm cerfcube_defconfig

All error/warnings:

   drivers/built-in.o: In function `__handle_sysrq':
>> clkdev.c:(.text+0xe390): undefined reference to `rcu_sysrq_start'
>> clkdev.c:(.text+0xe480): undefined reference to `rcu_sysrq_end'
>> clkdev.c:(.text+0xe4a4): undefined reference to `rcu_sysrq_end'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
