Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id EFC1B6B009F
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 01:46:49 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rr13so572203pbb.1
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 22:46:49 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qy5si22805127pab.311.2014.02.25.22.46.48
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 22:46:49 -0800 (PST)
Date: Wed, 26 Feb 2014 14:46:45 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 326/350] undefined reference to `tty_write_message'
Message-ID: <530d8dd5.N73la/TcxHdsINPu%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a6a1126d3535f0bd8d7c56810061541a4f5595af
commit: 5837644fad4fdcc7a812eb1f3a215d8196628627 [326/350] kconfig: make allnoconfig disable options behind EMBEDDED and EXPERT
config: make ARCH=ia64 allnoconfig

All error/warnings:

   arch/ia64/kernel/built-in.o: In function `ia64_handle_unaligned':
>> (.text+0x1b882): undefined reference to `tty_write_message'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
