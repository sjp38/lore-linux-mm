Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B34366B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 11:17:28 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fb1so2626794pad.24
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 08:17:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ck1si5044343pad.286.2014.04.25.08.17.27
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 08:17:27 -0700 (PDT)
Date: Fri, 25 Apr 2014 23:17:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mmotm:master 254/302] sysrq.c:undefined reference to
 `rcu_sysrq_start'
Message-ID: <20140425151717.GG31117@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   25153c2ef8124ecd930de79236e7fe25ad2507cb
commit: efc352dc40c65a04c848696805f0300cfb433c36 [254/302] sysrq,rcu: suppress RCU stall warnings while sysrq runs
config: make ARCH=xtensa common_defconfig

All error/warnings:

   drivers/built-in.o: In function `fb_register_client':
   (.text+0xb3b8): undefined reference to `rcu_sysrq_start'
   drivers/built-in.o: In function `fb_register_client':
   (.text+0xb3bc): undefined reference to `rcu_sysrq_end'
   drivers/built-in.o: In function `sysrq_disconnect':
>> sysrq.c:(.text+0x1365f): undefined reference to `rcu_sysrq_start'
   drivers/built-in.o: In function `sysrq_reinject_alt_sysrq':
>> sysrq.c:(.text+0x13723): undefined reference to `rcu_sysrq_end'
   net/built-in.o: In function `__netdev_adjacent_dev_remove':
   dev.c:(.text+0xe0d9): dangerous relocation: call8: misaligned call target: (.text.unlikely+0x63)
   net/built-in.o: In function `netdev_rx_csum_fault':
   (.text+0xfefc): dangerous relocation: call8: misaligned call target: (.text.unlikely+0x63)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
