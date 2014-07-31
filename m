Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CAA5C6B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 21:23:33 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so2564227pab.20
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 18:23:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id zi2si4081976pbb.138.2014.07.30.18.23.32
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 18:23:33 -0700 (PDT)
Date: Thu, 31 Jul 2014 09:20:51 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 463/499] Warning(kernel/time/timer.c:1462): No
 description found for parameter 'flag'
Message-ID: <53d999f3.YS6+PPaaBxjvzYie%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   2ba830748173b6c82eda725571aa403997bcbf3a
commit: 09a84737014b94cbb79d491c3aa8cc1d01379708 [463/499] timer: provide an api for deferrable timeout
reproduce: make htmldocs

All warnings:

   Warning(kernel/sched/fair.c:5906): No description found for parameter 'overload'
>> Warning(kernel/time/timer.c:1462): No description found for parameter 'flag'
   Warning(kernel/sys.c): no structured comments found
   Warning(drivers/base/dd.c:61): No description found for parameter 'work'
   Warning(drivers/dma-buf/fence.c:38): cannot understand function prototype: 'atomic_t fence_context_counter = ATOMIC_INIT(0); '
   Warning(drivers/dma-buf/seqno-fence.c): no structured comments found
   Warning(include/linux/seqno-fence.h:99): No description found for parameter 'cond'
   Warning(drivers/dma-buf/reservation.c): no structured comments found
   Warning(include/linux/reservation.h): no structured comments found
   Warning(drivers/message/fusion/mptbase.c:1411): Excess function parameter 'prod_name' description in 'mpt_get_product_name'
   Warning(drivers/message/fusion/mptbase.c:1411): Excess function parameter 'prod_name' description in 'mpt_get_product_name'
   Warning(include/linux/spi/spi.h:458): No description found for parameter 'can_dma'
   Warning(include/linux/spi/spi.h:458): No description found for parameter 'cur_msg_mapped'
   Warning(include/linux/spi/spi.h:458): No description found for parameter 'dma_tx'
   Warning(include/linux/spi/spi.h:458): No description found for parameter 'dma_rx'
   Warning(include/linux/spi/spi.h:458): No description found for parameter 'dummy_rx'
   Warning(include/linux/spi/spi.h:458): No description found for parameter 'dummy_tx'
   Warning(include/linux/spi/spi.h:686): No description found for parameter 'frame_length'
   Warning(drivers/spi/spi.c:857): No description found for parameter 'master'
   Warning(drivers/spi/spi.c:857): No description found for parameter 'master'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
