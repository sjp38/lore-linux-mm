Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D1C016B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:23:51 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so6477404pdb.21
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 21:23:51 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id li1si24570895pab.183.2014.06.23.21.23.50
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 21:23:50 -0700 (PDT)
Date: Tue, 24 Jun 2014 12:23:31 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 103/212] make[2]: *** No rule to make target
 `arch/powerpc/kvm/book3s_hv_cma.o', needed by
 `arch/powerpc/kvm/built-in.o'.
Message-ID: <53a8fd43.3YaWacNnJ4rMjQ6L%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   58ae500a03a6bf68eee323c342431bfdd3f460b6
commit: e58e263e5254df63f3997192322220748e4f6223 [103/212] PPC, KVM, CMA: use general CMA reserved area management framework
config: make ARCH=powerpc ppc64_defconfig

All error/warnings:

>> make[2]: *** No rule to make target `arch/powerpc/kvm/book3s_hv_cma.o', needed by `arch/powerpc/kvm/built-in.o'.
   make[2]: Target `__build' not remade because of errors.

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
