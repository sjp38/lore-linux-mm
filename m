Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 89F6F6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 09:48:41 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ld10so2725163pab.40
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 06:48:41 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id v5si5163007pbh.67.2014.03.06.06.48.40
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 06:48:40 -0800 (PST)
Date: Thu, 06 Mar 2014 22:48:11 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 452/458] undefined reference to
 `__bad_size_call_parameter'
Message-ID: <53188aab.D8+W+0kHpmaV0uFd%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   0ffb2fe7b9c30082876fa3a17da018bf0632cf03
commit: 3b0fc5a9f85472be761e51de110e0aa8d15e7f41 [452/458] sh: replace __get_cpu_var uses
config: make ARCH=sh r7785rp_defconfig

All error/warnings:

   arch/sh/kernel/built-in.o: In function `kprobe_exceptions_notify':
>> (.kprobes.text+0x8c8): undefined reference to `__bad_size_call_parameter'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
