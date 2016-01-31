Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 592BD6B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 15:52:13 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id mw1so20509996igb.1
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 12:52:13 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id pi9si10603041igb.76.2016.01.31.12.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jan 2016 12:52:11 -0800 (PST)
Date: Mon, 1 Feb 2016 07:52:07 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [linux-next:master 1875/2100] include/linux/jump_label.h:122:2:
 error: implicit declaration of function 'atomic_read'
Message-ID: <20160201075207.24869290@canb.auug.org.au>
In-Reply-To: <56AB4C1D.5090801@suse.cz>
References: <201601291512.vqk4lpvV%fengguang.wu@intel.com>
	<56AB3EEB.8090808@suse.cz>
	<20160129215335.1a049964@canb.auug.org.au>
	<56AB4C1D.5090801@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: kbuild test robot <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kbuild-all@01.org, linux-s390@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>

Hi Vlastimil,

On Fri, 29 Jan 2016 12:25:17 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
>
> Please replace the -fix with this patch. Sorry again.
> 
> ----8<----
> From 1e6b1ae6bf55410fb816cf910c4d91533642072b Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 29 Jan 2016 12:18:21 +0100
> Subject: [PATCH] mm, printk: introduce new format string for flags-fix
> 
> Due to rebasing mistake, mmdebug.h keeps including tracepoint.h, causing
> header dependency issues on some arches.
> Remove the include, and related declarations of flags arrays, which reside
> in mm/internal.h and lib/vsprintf.c already includes that header.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/mmdebug.h | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 3fb9bc65d61d..de7be78c6f0e 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -3,17 +3,11 @@
>  
>  #include <linux/bug.h>
>  #include <linux/stringify.h>
> -#include <linux/types.h>
> -#include <linux/tracepoint.h>
>  
>  struct page;
>  struct vm_area_struct;
>  struct mm_struct;
>  
> -extern const struct trace_print_flags pageflag_names[];
> -extern const struct trace_print_flags vmaflag_names[];
> -extern const struct trace_print_flags gfpflag_names[];
> -
>  extern void dump_page(struct page *page, const char *reason);
>  extern void __dump_page(struct page *page, const char *reason);
>  void dump_vma(const struct vm_area_struct *vma);
> -- 
> 2.7.0

OK, I have done that from today.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
