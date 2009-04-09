Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 58FE75F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 10:04:30 -0400 (EDT)
Subject: Re: [PATCH] mm: move the scan_unevictable_pages sysctl to the vm
	table
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1239270133.7647.213.camel@twins>
References: <1239270133.7647.213.camel@twins>
Content-Type: text/plain
Date: Thu, 09 Apr 2009 10:04:32 -0400
Message-Id: <1239285872.24817.20.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-09 at 11:42 +0200, Peter Zijlstra wrote:
> Subject: mm: move the scan_unevictable_pages sysctl to the vm table
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Thu Apr 09 11:38:45 CEST 2009
> 
> vm knobs should go in the vm table. Probably too late for randomize_va_space
> though.

I was surprised to see "scan_unevictable_pages" in the kernel table.
This must be the result of a merge glitch.  I originally put this at the
end of the vm table.  Just went back and looked at some older patches to
be sure.  E.g.,

	http://marc.info/?l=linux-mm&m=121321022603288&w=4

It had been moved to the kernel table by the time the unevictable lru
was merged upstream:

	http://marc.info/?l=linux-mm-commits&m=122453486931267&w=4

Anyway...

> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

> ---
>  kernel/sysctl.c |   20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> Index: linux-2.6/kernel/sysctl.c
> ===================================================================
> --- linux-2.6.orig/kernel/sysctl.c
> +++ linux-2.6/kernel/sysctl.c
> @@ -914,16 +914,6 @@ static struct ctl_table kern_table[] = {
>  		.proc_handler	= &proc_dointvec,
>  	},
>  #endif
> -#ifdef CONFIG_UNEVICTABLE_LRU
> -	{
> -		.ctl_name	= CTL_UNNUMBERED,
> -		.procname	= "scan_unevictable_pages",
> -		.data		= &scan_unevictable_pages,
> -		.maxlen		= sizeof(scan_unevictable_pages),
> -		.mode		= 0644,
> -		.proc_handler	= &scan_unevictable_handler,
> -	},
> -#endif
>  #ifdef CONFIG_SLOW_WORK
>  	{
>  		.ctl_name	= CTL_UNNUMBERED,
> @@ -1324,6 +1314,16 @@ static struct ctl_table vm_table[] = {
>  		.extra2		= &one,
>  	},
>  #endif
> +#ifdef CONFIG_UNEVICTABLE_LRU
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "scan_unevictable_pages",
> +		.data		= &scan_unevictable_pages,
> +		.maxlen		= sizeof(scan_unevictable_pages),
> +		.mode		= 0644,
> +		.proc_handler	= &scan_unevictable_handler,
> +	},
> +#endif
>  /*
>   * NOTE: do not add new entries to this table unless you have read
>   * Documentation/sysctl/ctl_unnumbered.txt
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
