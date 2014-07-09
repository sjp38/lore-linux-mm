Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CDCAE6B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:14:20 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so9095234pac.33
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:14:20 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id w11si7219275pdj.269.2014.07.09.04.14.18
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 04:14:19 -0700 (PDT)
Date: Wed, 09 Jul 2014 19:13:41 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 284/379] :undefined reference to
 `crypto_alloc_shash'
Message-ID: <53bd23e5.Zuv44zZmJKnR/Dh5%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   35fcf5dd2a7d038c0fcbc161e353d73497350b86
commit: ba0dc4038c9fec5fa2f94756065f02b8011f270b [284/379] kexec: load and relocate purgatory at kernel load time
config: make ARCH=arm nuc950_defconfig

All error/warnings:

   kernel/built-in.o: In function `sys_kexec_file_load':
>> :(.text+0x4c808): undefined reference to `crypto_alloc_shash'
>> :(.text+0x4c8d4): undefined reference to `crypto_shash_update'
>> :(.text+0x4c918): undefined reference to `crypto_shash_update'
>> :(.text+0x4c9f4): undefined reference to `crypto_shash_final'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
