Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 889D16B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 04:37:30 -0400 (EDT)
Date: Tue, 5 May 2009 09:36:14 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Double check memmap is actually valid with a memmap
	has unexpected holes
Message-ID: <20090505083614.GA28688@n2100.arm.linux.org.uk>
References: <20090505082944.GA25904@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090505082944.GA25904@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hartleys@visionengravers.com, mcrapet@gmail.com, fred99@carolina.rr.com, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Tue, May 05, 2009 at 09:29:44AM +0100, Mel Gorman wrote:
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index e02b893..6d79051 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -925,10 +925,9 @@ config OABI_COMPAT
>  	  UNPREDICTABLE (in fact it can be predicted that it won't work
>  	  at all). If in doubt say Y.
>  
> -config ARCH_FLATMEM_HAS_HOLES
> +config ARCH_HAS_HOLES_MEMORYMODEL

Can we arrange for EP93xx to select this so we don't have it enabled for
everyone.

The other user of this was RPC when it was flatmem only, but since it has
been converted to sparsemem it's no longer an issue there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
