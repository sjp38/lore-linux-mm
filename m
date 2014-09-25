Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 601D06B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 13:21:32 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so9412623wiv.14
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 10:21:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ks9si3553411wjb.72.2014.09.25.10.21.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Sep 2014 10:21:31 -0700 (PDT)
Date: Thu, 25 Sep 2014 13:21:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Support compiling out madvise and fadvise
Message-ID: <20140925172113.GA8209@cmpxchg.org>
References: <20140922161109.GA25027@thin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140922161109.GA25027@thin>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 22, 2014 at 09:11:16AM -0700, Josh Triplett wrote:
> @@ -3,7 +3,7 @@
>  #
>  
>  mmu-y			:= nommu.o
> -mmu-$(CONFIG_MMU)	:= fremap.o gup.o highmem.o madvise.o memory.o mincore.o \
> +mmu-$(CONFIG_MMU)	:= fremap.o gup.o highmem.o memory.o mincore.o \
>  			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
>  			   vmalloc.o pagewalk.o pgtable-generic.o
>  
> @@ -11,7 +11,7 @@ ifdef CONFIG_CROSS_MEMORY_ATTACH
>  mmu-$(CONFIG_MMU)	+= process_vm_access.o
>  endif
>  
> -obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
> +obj-y			:= filemap.o mempool.o oom_kill.o \
>  			   maccess.o page_alloc.o page-writeback.o \
>  			   readahead.o swap.o truncate.o vmscan.o shmem.o \
>  			   util.o mmzone.o vmstat.o backing-dev.o \
> @@ -28,6 +28,9 @@ else
>  	obj-y		+= bootmem.o
>  endif
>  
> +ifdef CONFIG_MMU
> +	obj-$(CONFIG_ADVISE_SYSCALLS)	+= fadvise.o madvise.o
> +endif

That makes fadvise MMU-only, but I don't see why it should be.

Was that intentional?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
