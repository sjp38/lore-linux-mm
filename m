Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A41C56B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 19:56:25 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so13372115pad.21
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 16:56:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id bg4si31501804pbb.67.2014.07.02.16.56.21
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 16:56:24 -0700 (PDT)
Date: Thu, 03 Jul 2014 07:55:06 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 289/396] undefined reference to
 `crypto_alloc_shash'
Message-ID: <53b49bda.Alc8D1c/m4kIm3gZ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   82b56f797fa200a5e9feac3a93cb6496909b9670
commit: 025d75374c9c08274f60da5802381a8ef7490388 [289/396] kexec: load and relocate purgatory at kernel load time
config: make ARCH=s390 allnoconfig

All error/warnings:

   kernel/built-in.o: In function `sys_kexec_file_load':
   (.text+0x32314): undefined reference to `crypto_shash_final'
   kernel/built-in.o: In function `sys_kexec_file_load':
   (.text+0x32328): undefined reference to `crypto_shash_update'
   kernel/built-in.o: In function `sys_kexec_file_load':
>> (.text+0x32338): undefined reference to `crypto_alloc_shash'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
