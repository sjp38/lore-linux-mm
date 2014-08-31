Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C18C96B0035
	for <linux-mm@kvack.org>; Sat, 30 Aug 2014 23:18:18 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id f51so3867813qge.2
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 20:18:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e109si6167394qgf.40.2014.08.30.20.18.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Aug 2014 20:18:17 -0700 (PDT)
Date: Sat, 30 Aug 2014 22:43:17 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [mmotm:master 140/287] mm/page_alloc.c:6737:46: error:
 'pgprot_t' has no member named 'pgprot'
Message-ID: <20140831024317.GA7269@nhori>
References: <54011800.d8MKnT8qiZd6dbb6%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54011800.d8MKnT8qiZd6dbb6%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Sat, Aug 30, 2014 at 08:17:04AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
> commit: 59f16a3915d3e5c6ddebc1b1c10ce0c14fd518cf [140/287] mm: introduce dump_vma
> config: make ARCH=tile tilegx_defconfig
> 
> All error/warnings:
> 
>    mm/page_alloc.c: In function 'dump_vma':
> >> mm/page_alloc.c:6737:46: error: 'pgprot_t' has no member named 'pgprot'
> 
> vim +6737 mm/page_alloc.c
> 
>   6731		printk(KERN_ALERT
>   6732			"vma %p start %p end %p\n"
>   6733			"next %p prev %p mm %p\n"
>   6734			"prot %lx anon_vma %p vm_ops %p\n"
>   6735			"pgoff %lx file %p private_data %p\n",
>   6736			vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
> > 6737			vma->vm_prev, vma->vm_mm, vma->vm_page_prot.pgprot,
>   6738			vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
>   6739			vma->vm_file, vma->vm_private_data);
>   6740		dump_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names));

pgprot_t is defined differently by arch, so we should access the contents
via pgprot_val() macro.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
