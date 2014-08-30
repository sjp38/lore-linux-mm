Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B82D66B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 20:17:41 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y13so1484771pdi.37
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 17:17:41 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ng7si2073798pbc.58.2014.08.29.17.17.40
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 17:17:40 -0700 (PDT)
Date: Sat, 30 Aug 2014 08:17:04 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 140/287] mm/page_alloc.c:6737:46: error: 'pgprot_t' has no member named 'pgprot'
Message-ID: <54011800.d8MKnT8qiZd6dbb6%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
commit: 59f16a3915d3e5c6ddebc1b1c10ce0c14fd518cf [140/287] mm: introduce dump_vma
config: make ARCH=tile tilegx_defconfig

All error/warnings:

   mm/page_alloc.c: In function 'dump_vma':
>> mm/page_alloc.c:6737:46: error: 'pgprot_t' has no member named 'pgprot'

vim +6737 mm/page_alloc.c

  6731		printk(KERN_ALERT
  6732			"vma %p start %p end %p\n"
  6733			"next %p prev %p mm %p\n"
  6734			"prot %lx anon_vma %p vm_ops %p\n"
  6735			"pgoff %lx file %p private_data %p\n",
  6736			vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
> 6737			vma->vm_prev, vma->vm_mm, vma->vm_page_prot.pgprot,
  6738			vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
  6739			vma->vm_file, vma->vm_private_data);
  6740		dump_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names));

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
