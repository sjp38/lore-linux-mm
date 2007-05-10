Message-ID: <4642C788.1080309@yahoo.com.au>
Date: Thu, 10 May 2007 17:19:36 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] slob: implement RCU freeing
References: <Pine.LNX.4.64.0705081746500.16914@schroedinger.engr.sgi.com> <20070509012725.GZ11115@waste.org> <Pine.LNX.4.64.0705081828300.17376@schroedinger.engr.sgi.com> <20070508.185141.85412154.davem@davemloft.net> <46412BB5.1060605@yahoo.com.au> <20070509174238.b4152887.akpm@linux-foundation.org> <46426EA1.4030408@yahoo.com.au> <20070510022707.GO11115@waste.org> <4642C6A2.1090809@yahoo.com.au>
In-Reply-To: <4642C6A2.1090809@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Matt Mackall wrote:
> 
>> Looks good to me, but haven't had time to actually test it.
>>
>> Acked-by: Matt Mackall <mpm@selenic.com>
> 
> 
> Updated to current, added a comment, and test booted it again.
> Works OK.
> 
> 
> ------------------------------------------------------------------------
> 
> The SLOB allocator should implement SLAB_DESTROY_BY_RCU correctly, because even
> on UP, RCU freeing semantics are not equivalent to simply freeing immediately.
> This also allows SLOB to be used on SMP.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> Acked-by: Matt Mackall <mpm@selenic.com>
> 
> Index: linux-2.6/init/Kconfig
> ===================================================================
> --- linux-2.6.orig/init/Kconfig	2007-05-10 14:17:38.000000000 +1000
> +++ linux-2.6/init/Kconfig	2007-05-10 14:18:11.000000000 +1000
> @@ -519,7 +519,8 @@
>  	  slab allocator.
>  
>  config SLUB
> -	depends on EXPERIMENTAL && !ARCH_USES_SLAB_PAGE_STRUCT
> +#	depends on EXPERIMENTAL && !ARCH_USES_SLAB_PAGE_STRUCT
> +	depends on EXPERIMENTAL
>  	bool "SLUB (Unqueued Allocator)"
>  	help
>  	   SLUB is a slab allocator that minimizes cache line usage
> @@ -529,15 +530,11 @@

Ooops, sorry this hunk leaked in because I wanted to test compile slub :P

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
