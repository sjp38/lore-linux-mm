Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 44DD96B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 04:10:45 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so7280129wiv.7
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 01:10:44 -0800 (PST)
Received: from cpsmtpb-ews02.kpnxchange.com (cpsmtpb-ews02.kpnxchange.com. [213.75.39.5])
        by mx.google.com with ESMTP id y7si31672285wjy.65.2014.12.22.01.10.43
        for <linux-mm@kvack.org>;
        Mon, 22 Dec 2014 01:10:43 -0800 (PST)
Message-ID: <1419239442.30945.5.camel@x220>
Subject: Re: [PATCH v3 2/8] mm/debug-pagealloc: prepare boottime
 configurable on/off
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 22 Dec 2014 10:10:42 +0100
In-Reply-To: <20141128073524.GC11802@js1304-P5Q-DELUXE>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <1416816926-7756-3-git-send-email-iamjoonsoo.kim@lge.com>
	 <1417091739.29407.95.camel@x220> <20141128073524.GC11802@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Valentin Rothberg <valentinrothberg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Joonsoo,

On Fri, 2014-11-28 at 16:35 +0900, Joonsoo Kim wrote:
> Hello, Paul.
> 
> Thanks for spotting this.
> I attach the patch. :)
> 
> Andrew,
> Could you kindly fold this into the patch in your tree?
> 
> Thanks.
> 
> ------------------->8---------------
> From a33c480160904cc93333807a448960151ac4c534 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Fri, 28 Nov 2014 16:05:32 +0900
> Subject: [PATCH] mm/debug_pagealloc: remove obsolete Kconfig options
> 
> These are obsolete since commit "mm/debug-pagealloc: prepare boottime
> configurable" is merged. So, remove it.
> 
> [pebolle@tiscali.nl: find obsolete Kconfig options]
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/Kconfig.debug |    9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
> index 56badfc..957d3da 100644
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug
> @@ -14,7 +14,6 @@ config DEBUG_PAGEALLOC
>  	depends on !KMEMCHECK
>  	select PAGE_EXTENSION
>  	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
> -	select PAGE_GUARD if ARCH_SUPPORTS_DEBUG_PAGEALLOC
>  	---help---
>  	  Unmap pages from the kernel linear mapping after free_pages().
>  	  This results in a large slowdown, but helps to find certain types
> @@ -27,13 +26,5 @@ config DEBUG_PAGEALLOC
>  	  that would result in incorrect warnings of memory corruption after
>  	  a resume because free pages are not saved to the suspend image.
>  
> -config WANT_PAGE_DEBUG_FLAGS
> -	bool
> -
>  config PAGE_POISONING
>  	bool
> -	select WANT_PAGE_DEBUG_FLAGS
> -
> -config PAGE_GUARD
> -	bool
> -	select WANT_PAGE_DEBUG_FLAGS

This patch didn't make it into v3.19-rc1. And I think it never entered
linux-next. Did this fall through the cracks or was there some other
issue with this patch?

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
