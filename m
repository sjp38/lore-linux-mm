Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2C71E6B0035
	for <linux-mm@kvack.org>; Mon,  1 Sep 2014 23:33:16 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so13566289pad.27
        for <linux-mm@kvack.org>; Mon, 01 Sep 2014 20:33:15 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id z1si3765499pas.101.2014.09.01.20.33.14
        for <linux-mm@kvack.org>;
        Mon, 01 Sep 2014 20:33:15 -0700 (PDT)
Date: Tue, 02 Sep 2014 11:32:13 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 2850/2956] mm/page_alloc.c:6739:3: warning: format
 '%lx' expects argument of type 'long unsigned int', but argument 8 has type 'long long unsigned int'
Message-ID: <54053a3d.W7Lf0ZQMGeHXkMg+%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mark Brown <broonie@sirena.org.uk>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   03af78748485f63e8ed21d2e2585b5d1ec862ba6
commit: 658f7da49d34bc6187e6cd1ec57933d1a2a76035 [2850/2956] mm: introduce dump_vma
config: make ARCH=sh apsh4ad0a_defconfig

All warnings:

   mm/page_alloc.c: In function 'dump_vma':
>> mm/page_alloc.c:6739:3: warning: format '%lx' expects argument of type 'long unsigned int', but argument 8 has type 'long long unsigned int' [-Wformat]
   mm/page_alloc.c: In function 'free_area_init_nodes':
   mm/page_alloc.c:5362:34: warning: array subscript is below array bounds [-Warray-bounds]

vim +6739 mm/page_alloc.c

  6723		{VM_MIXEDMAP,			"mixedmap"	},
  6724		{VM_HUGEPAGE,			"hugepage"	},
  6725		{VM_NOHUGEPAGE,			"nohugepage"	},
  6726		{VM_MERGEABLE,			"mergeable"	},
  6727	};
  6728	
  6729	void dump_vma(const struct vm_area_struct *vma)
  6730	{
  6731		printk(KERN_ALERT
  6732			"vma %p start %p end %p\n"
  6733			"next %p prev %p mm %p\n"
  6734			"prot %lx anon_vma %p vm_ops %p\n"
  6735			"pgoff %lx file %p private_data %p\n",
  6736			vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
  6737			vma->vm_prev, vma->vm_mm, vma->vm_page_prot.pgprot,
  6738			vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
> 6739			vma->vm_file, vma->vm_private_data);
  6740		dump_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names));
  6741	}
  6742	EXPORT_SYMBOL(dump_vma);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
