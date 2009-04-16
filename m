Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 343DC5F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 04:54:22 -0400 (EDT)
Subject: Re: [patch 5/5] mm: prompt slqb default for oldconfig
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090414165058.GE14873@wotan.suse.de>
References: <20090414164439.GA14873@wotan.suse.de>
	 <20090414165058.GE14873@wotan.suse.de>
Date: Thu, 16 Apr 2009 11:55:09 +0300
Message-Id: <1239872109.15377.7.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Tue, 2009-04-14 at 18:50 +0200, Nick Piggin wrote:
> Hi Pekka,
> 
> Well there have been reasonably significant changes both for SLQB and
> SLUB that I thought it is better to wait one more round before merging
> SLQB. Also, SLQB may not have been getting as much testing as it could
> have in -next, due to oldconfig choosing existing config as the default.
> 
> Thanks,
> Nick
> --
> 
> Change Kconfig names for slab allocator choices to prod SLQB into being
> the default. Hopefully increasing testing base.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

I went ahead and applied this too. IIRC, Ingo had some ideas how this
should be handled so lets CC him as well.

			Pekka

> ---
> Index: linux-2.6/init/Kconfig
> ===================================================================
> --- linux-2.6.orig/init/Kconfig	2009-04-15 02:36:05.000000000 +1000
> +++ linux-2.6/init/Kconfig	2009-04-15 02:41:25.000000000 +1000
> @@ -975,18 +975,23 @@ config COMPAT_BRK
>  
>  choice
>  	prompt "Choose SLAB allocator"
> -	default SLQB
> +	default SLQB_ALLOCATOR
>  	help
>  	   This option allows to select a slab allocator.
>  
> -config SLAB
> +config SLAB_ALLOCATOR
>  	bool "SLAB"
>  	help
>  	  The regular slab allocator that is established and known to work
>  	  well in all environments. It organizes cache hot objects in
>  	  per cpu and per node queues.
>  
> -config SLUB
> +config SLAB
> +	bool
> +	default y
> +	depends on SLAB_ALLOCATOR
> +
> +config SLUB_ALLOCATOR
>  	bool "SLUB (Unqueued Allocator)"
>  	help
>  	   SLUB is a slab allocator that minimizes cache line usage
> @@ -996,11 +1001,21 @@ config SLUB
>  	   and has enhanced diagnostics. SLUB is the default choice for
>  	   a slab allocator.
>  
> -config SLQB
> +config SLUB
> +	bool
> +	default y
> +	depends on SLUB_ALLOCATOR
> +
> +config SLQB_ALLOCATOR
>  	bool "SLQB (Queued allocator)"
>  	help
>  	  SLQB is a proposed new slab allocator.
>  
> +config SLQB
> +	bool
> +	default y
> +	depends on SLQB_ALLOCATOR
> +
>  config SLOB
>  	depends on EMBEDDED
>  	bool "SLOB (Simple Allocator)"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
