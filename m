Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 278F96B0641
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 19:28:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q189so184672wmd.6
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 16:28:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g77si283924wmc.166.2017.08.02.16.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 16:28:00 -0700 (PDT)
Date: Wed, 2 Aug 2017 16:27:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 5/7] mm: make tlb_flush_pending global
Message-Id: <20170802162758.40760a1e3cbb24b10e1c4144@linux-foundation.org>
In-Reply-To: <201708022224.e3s8yqcJ%fengguang.wu@intel.com>
References: <20170802000818.4760-6-namit@vmware.com>
	<201708022224.e3s8yqcJ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Nadav Amit <namit@vmware.com>, kbuild-all@01.org, linux-mm@kvack.org, nadav.amit@gmail.com, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

On Wed, 2 Aug 2017 22:28:47 +0800 kbuild test robot <lkp@intel.com> wrote:

> Hi Minchan,
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.13-rc3]
> [cannot apply to next-20170802]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-migrate-prevent-racy-access-to-tlb_flush_pending/20170802-205715
> config: sh-allyesconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sh 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/printk.h:6:0,
>                     from include/linux/kernel.h:13,
>                     from mm/debug.c:8:
>    mm/debug.c: In function 'dump_mm':
> >> include/linux/kern_levels.h:4:18: warning: format '%lx' expects argument of type 'long unsigned int', but argument 40 has type 'int' [-Wformat=]
>
> ...
>

This?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-make-tlb_flush_pending-global-fix

remove more ifdefs from world's ugliest printk statement

Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nadav Amit <namit@vmware.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/debug.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN include/linux/mm_types.h~mm-make-tlb_flush_pending-global-fix include/linux/mm_types.h
diff -puN mm/debug.c~mm-make-tlb_flush_pending-global-fix mm/debug.c
--- a/mm/debug.c~mm-make-tlb_flush_pending-global-fix
+++ a/mm/debug.c
@@ -124,9 +124,7 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_NUMA_BALANCING
 		"numa_next_scan %lu numa_scan_offset %lu numa_scan_seq %d\n"
 #endif
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 		"tlb_flush_pending %d\n"
-#endif
 		"def_flags: %#lx(%pGv)\n",
 
 		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
