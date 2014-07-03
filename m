Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E8A3C6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 03:38:12 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so13959290pad.12
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 00:38:12 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id so9si31286955pac.191.2014.07.03.00.38.10
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 00:38:11 -0700 (PDT)
Date: Thu, 03 Jul 2014 15:37:02 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 284/380] hw_breakpoint.c:undefined reference to
 `crypto_alloc_shash'
Message-ID: <53b5081e.BC/7rMXRR7sro0g1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   0e9ce823ad7bc6b85c279223ae6638d47089461e
commit: ba0dc4038c9fec5fa2f94756065f02b8011f270b [284/380] kexec: load and relocate purgatory at kernel load time
config: make ARCH=arm koelsch_defconfig

All error/warnings:

   kernel/built-in.o: In function `sys_kexec_file_load':
>> hw_breakpoint.c:(.text+0x56c98): undefined reference to `crypto_alloc_shash'
>> hw_breakpoint.c:(.text+0x56d54): undefined reference to `crypto_shash_update'
>> hw_breakpoint.c:(.text+0x56d90): undefined reference to `crypto_shash_update'
>> hw_breakpoint.c:(.text+0x56df4): undefined reference to `crypto_shash_final'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
