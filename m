Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0632E6B0253
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 13:31:49 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so161023260pab.0
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 10:31:48 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b185si32957989pfa.125.2016.08.16.10.31.48
        for <linux-mm@kvack.org>;
        Tue, 16 Aug 2016 10:31:48 -0700 (PDT)
Date: Tue, 16 Aug 2016 18:31:44 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Avoid using __va() on addresses that don't
 have a lowmem mapping
Message-ID: <20160816173143.GC7609@e104818-lin.cambridge.arm.com>
References: <1471360856-16916-1-git-send-email-catalin.marinas@arm.com>
 <201608170130.HGiTRP7J%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201608170130.HGiTRP7J%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vignesh R <vigneshr@ti.com>

On Wed, Aug 17, 2016 at 01:15:53AM +0800, kbuild test robot wrote:
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.8-rc2 next-20160816]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Catalin-Marinas/mm-kmemleak-Avoid-using-__va-on-addresses-that-don-t-have-a-lowmem-mapping/20160816-232733
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: tile-tilegx_defconfig (attached as .config)
> compiler: tilegx-linux-gcc (GCC) 4.6.2
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=tile 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/kmemleak.h:24:0,
>    from include/linux/slab.h:117,
>    from arch/tile/include/asm/pgtable.h:27,
>    from mm/init-mm.c:9:
>    include/linux/mm.h: In function 'is_vmalloc_addr':
>    include/linux/mm.h:486:17: error: 'VMALLOC_START' undeclared (first use in this function)
>    include/linux/mm.h:486:17: note: each undeclared identifier is reported only once for each function it appears in
>    include/linux/mm.h:486:41: error: 'VMALLOC_END' undeclared (first use in this function)
>    include/linux/mm.h: In function 'maybe_mkwrite':
>    include/linux/mm.h:624:3: error: implicit declaration of function 'pte_mkwrite'
>    include/linux/mm.h:624:7: error: incompatible types when assigning to type 'pte_t' from type 'int'
>    In file included from include/linux/kmemleak.h:24:0,
>    from include/linux/slab.h:117,
>    from arch/tile/include/asm/pgtable.h:27,
>    from mm/init-mm.c:9:

It looks like some architectures don't really like including linux/mm.h
from linux/kmemleak.h. I'll change the patch to avoid this include and
explicitly declare high_memory in kmemleak.h

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
