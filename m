Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F11576B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 04:38:21 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so5534898pab.36
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 01:38:21 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pu6si9954081pac.143.2014.04.28.01.38.20
        for <linux-mm@kvack.org>;
        Mon, 28 Apr 2014 01:38:20 -0700 (PDT)
Date: Mon, 28 Apr 2014 16:35:08 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 249/284] hid-monterey.c:undefined reference to
 `rcu_sysrq_start'
Message-ID: <535e12bc.Mpyh5/nJ9mYhQF9P%fengguang.wu@intel.com>
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
config: make ARCH=arm iop33x_defconfig

All error/warnings:

   drivers/built-in.o: In function `__handle_sysrq':
>> hid-monterey.c:(.text+0x24fd0): undefined reference to `rcu_sysrq_start'
>> hid-monterey.c:(.text+0x250c0): undefined reference to `rcu_sysrq_end'
>> hid-monterey.c:(.text+0x250e4): undefined reference to `rcu_sysrq_end'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
