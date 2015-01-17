Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE676B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 20:32:45 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id a1so1283700wgh.0
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 17:32:44 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id eh3si7213636wib.85.2015.01.16.17.32.44
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 17:32:44 -0800 (PST)
Date: Sat, 17 Jan 2015 03:32:25 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mmotm:master 162/365] mm/mmap.c:2858:46: error: 'PUD_SHIFT'
 undeclared
Message-ID: <20150117013225.GB3614@node.dhcp.inet.fi>
References: <201501170847.915ITc9r%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201501170847.915ITc9r%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Jan 17, 2015 at 08:56:48AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   59f7a5af1a6c9e19c6e5152f26548c494a2d7338
> commit: c824a9dc5e8821ce083652d4f728e804161d3dd0 [162/365] mm: account pmd page tables to the process
> config: microblaze-mmu_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout c824a9dc5e8821ce083652d4f728e804161d3dd0
>   # save the attached .config to linux build tree
>   make.cross ARCH=microblaze 
> 
> All error/warnings:
> 
>    In file included from arch/microblaze/include/asm/bug.h:1:0,
>                     from include/linux/bug.h:4,
>                     from include/linux/thread_info.h:11,
>                     from include/asm-generic/preempt.h:4,
>                     from arch/microblaze/include/generated/asm/preempt.h:1,
>                     from include/linux/preempt.h:18,
>                     from include/linux/spinlock.h:50,
>                     from include/linux/mmzone.h:7,
>                     from include/linux/gfp.h:5,
>                     from include/linux/slab.h:14,
>                     from mm/mmap.c:12:
>    mm/mmap.c: In function 'exit_mmap':
> >> mm/mmap.c:2858:46: error: 'PUD_SHIFT' undeclared (first use in this function)
>        round_up(FIRST_USER_ADDRESS, PUD_SIZE) >> PUD_SHIFT);
>                                                  ^
>    include/asm-generic/bug.h:86:25: note: in definition of macro 'WARN_ON'
>      int __ret_warn_on = !!(condition);    \
>                             ^
>    mm/mmap.c:2858:46: note: each undeclared identifier is reported only once for each function it appears in
>        round_up(FIRST_USER_ADDRESS, PUD_SIZE) >> PUD_SHIFT);
>                                                  ^
>    include/asm-generic/bug.h:86:25: note: in definition of macro 'WARN_ON'
>      int __ret_warn_on = !!(condition);    \
>                             ^
> 
> vim +/PUD_SHIFT +2858 mm/mmap.c
> 
>   2852		}
>   2853		vm_unacct_memory(nr_accounted);
>   2854	
>   2855		WARN_ON(atomic_long_read(&mm->nr_ptes) >
>   2856				round_up(FIRST_USER_ADDRESS, PMD_SIZE) >> PMD_SHIFT);
>   2857		WARN_ON(mm_nr_pmds(mm) >
> > 2858				round_up(FIRST_USER_ADDRESS, PUD_SIZE) >> PUD_SHIFT);
>   2859	}
>   2860	
>   2861	/* Insert vm structure into process list sorted by address
