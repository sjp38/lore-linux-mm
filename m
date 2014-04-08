Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4F86B0035
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 14:21:37 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so1010856eek.4
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 11:21:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si3894903eeg.91.2014.04.08.11.21.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 11:21:36 -0700 (PDT)
Date: Tue, 8 Apr 2014 20:21:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 09/22] Remove mm/filemap_xip.c
Message-ID: <20140408182135.GB26019@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <69ab315f0124881ae74d9881c48c7bdc70368fd1.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <69ab315f0124881ae74d9881c48c7bdc70368fd1.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:35, Matthew Wilcox wrote:
> It is now empty as all of its contents have been replaced by fs/xip.c
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  mm/Makefile      |  1 -
>  mm/filemap_xip.c | 23 -----------------------
>  2 files changed, 24 deletions(-)
>  delete mode 100644 mm/filemap_xip.c
> 
> diff --git a/mm/Makefile b/mm/Makefile
> index 310c90a..454c176 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -47,7 +47,6 @@ obj-$(CONFIG_SLUB) += slub.o
>  obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
>  obj-$(CONFIG_FAILSLAB) += failslab.o
>  obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
> -obj-$(CONFIG_FS_XIP) += filemap_xip.o
>  obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> deleted file mode 100644
> index 6316578..0000000
> --- a/mm/filemap_xip.c
> +++ /dev/null
> @@ -1,23 +0,0 @@
> -/*
> - *	linux/mm/filemap_xip.c
> - *
> - * Copyright (C) 2005 IBM Corporation
> - * Author: Carsten Otte <cotte@de.ibm.com>
> - *
> - * derived from linux/mm/filemap.c - Copyright (C) Linus Torvalds
> - *
> - */
> -
> -#include <linux/fs.h>
> -#include <linux/pagemap.h>
> -#include <linux/export.h>
> -#include <linux/uio.h>
> -#include <linux/rmap.h>
> -#include <linux/mmu_notifier.h>
> -#include <linux/sched.h>
> -#include <linux/seqlock.h>
> -#include <linux/mutex.h>
> -#include <linux/gfp.h>
> -#include <asm/tlbflush.h>
> -#include <asm/io.h>
> -
> -- 
> 1.9.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
