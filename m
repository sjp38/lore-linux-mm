Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B82BC6B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 06:12:53 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so25413394wmi.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 03:12:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t82si17933055wmg.0.2017.01.24.03.12.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 03:12:52 -0800 (PST)
Date: Tue, 24 Jan 2017 12:12:48 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/3] 1G transparent hugepage support for device dax
Message-ID: <20170124111248.GC20153@quack2.suse.cz>
References: <148521477073.31533.17781371321988910714.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148521477073.31533.17781371321988910714.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

On Mon 23-01-17 16:47:18, Dave Jiang wrote:
> The following series implements support for 1G trasparent hugepage on
> x86 for device dax. The bulk of the code was written by Mathew Wilcox
> a while back supporting transparent 1G hugepage for fs DAX. I have
> forward ported the relevant bits to 4.10-rc. The current submission has
> only the necessary code to support device DAX.

Well, you should really explain why do we want this functionality... Is
anybody going to use it? Why would he want to and what will he gain by
doing so? Because so far I haven't heard of a convincing usecase.

								Honza
> 
> ---
> 
> Dave Jiang (1):
>       dax: Support for transparent PUD pages for device DAX
> 
> Matthew Wilcox (2):
>       mm,fs,dax: Change ->pmd_fault to ->huge_fault
>       mm,x86: Add support for PUD-sized transparent hugepages
> 
> 
>  arch/Kconfig                          |    3 
>  arch/x86/Kconfig                      |    1 
>  arch/x86/include/asm/paravirt.h       |   11 +
>  arch/x86/include/asm/paravirt_types.h |    2 
>  arch/x86/include/asm/pgtable-2level.h |   17 ++
>  arch/x86/include/asm/pgtable-3level.h |   24 +++
>  arch/x86/include/asm/pgtable.h        |  145 +++++++++++++++++++
>  arch/x86/include/asm/pgtable_64.h     |   15 ++
>  arch/x86/kernel/paravirt.c            |    1 
>  arch/x86/mm/pgtable.c                 |   31 ++++
>  drivers/dax/dax.c                     |   82 ++++++++---
>  fs/dax.c                              |   43 ++++--
>  fs/ext2/file.c                        |    2 
>  fs/ext4/file.c                        |    6 -
>  fs/xfs/xfs_file.c                     |   10 +
>  fs/xfs/xfs_trace.h                    |    2 
>  include/asm-generic/pgtable.h         |   75 +++++++++-
>  include/asm-generic/tlb.h             |   14 ++
>  include/linux/dax.h                   |    6 -
>  include/linux/huge_mm.h               |   83 ++++++++++-
>  include/linux/mm.h                    |   40 +++++
>  include/linux/mmu_notifier.h          |   14 ++
>  include/linux/pfn_t.h                 |    8 +
>  mm/gup.c                              |    7 +
>  mm/huge_memory.c                      |  249 +++++++++++++++++++++++++++++++++
>  mm/memory.c                           |  102 ++++++++++++--
>  mm/pagewalk.c                         |   20 +++
>  mm/pgtable-generic.c                  |   14 ++
>  28 files changed, 952 insertions(+), 75 deletions(-)
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
