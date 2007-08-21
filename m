Date: Tue, 21 Aug 2007 16:25:13 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC][PATCH 3/9] pagemap: use PAGE_MASK/PAGE_ALIGN()
Message-ID: <20070821212512.GI30556@waste.org>
References: <20070821204248.0F506A29@kernel> <20070821204250.65D94559@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070821204250.65D94559@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 21, 2007 at 01:42:50PM -0700, Dave Hansen wrote:
> 
> Use existing macros (PAGE_MASK/PAGE_ALIGN()) instead of
> open-coding them.
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Acked-by: Matt Mackall <mpm@selenic.com>

> ---
> 
>  lxc-dave/fs/proc/task_mmu.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff -puN fs/proc/task_mmu.c~pagemap-use-PAGE_MASK fs/proc/task_mmu.c
> --- lxc/fs/proc/task_mmu.c~pagemap-use-PAGE_MASK	2007-08-21 13:30:51.000000000 -0700
> +++ lxc-dave/fs/proc/task_mmu.c	2007-08-21 13:30:51.000000000 -0700
> @@ -617,9 +617,9 @@ static ssize_t pagemap_read(struct file 
>  		goto out;
>  
>  	ret = -ENOMEM;
> -	uaddr = (unsigned long)buf & ~(PAGE_SIZE-1);
> +	uaddr = (unsigned long)buf & PAGE_MASK;
>  	uend = (unsigned long)(buf + count);
> -	pagecount = (uend - uaddr + PAGE_SIZE-1) / PAGE_SIZE;
> +	pagecount = (PAGE_ALIGN(uend) - uaddr) / PAGE_SIZE;
>  	pages = kmalloc(pagecount * sizeof(struct page *), GFP_KERNEL);
>  	if (!pages)
>  		goto out_task;
> _

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
