Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4681D6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 04:43:19 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so13520508pdi.27
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 01:43:18 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id lr7si32402491pab.151.2014.07.03.01.43.16
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 01:43:18 -0700 (PDT)
Date: Thu, 03 Jul 2014 16:40:04 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 284/380] cpu_pm.c:undefined reference to
 `crypto_alloc_shash'
Message-ID: <53b516e4.rgxkJyIm0d6ktGNY%fengguang.wu@intel.com>
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
config: make ARCH=arm nuc950_defconfig

All error/warnings:

   kernel/built-in.o: In function `sys_kexec_file_load':
>> cpu_pm.c:(.text+0x4a580): undefined reference to `crypto_alloc_shash'
>> cpu_pm.c:(.text+0x4a654): undefined reference to `crypto_shash_update'
>> cpu_pm.c:(.text+0x4a698): undefined reference to `crypto_shash_update'
>> cpu_pm.c:(.text+0x4a778): undefined reference to `crypto_shash_final'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
