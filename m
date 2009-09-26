Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BB1CC6B0055
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 12:18:55 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A77BE82C898
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 12:21:39 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZNpVPaVuGSKh for <linux-mm@kvack.org>;
	Sat, 26 Sep 2009 12:21:39 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DD0F582C921
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 12:21:34 -0400 (EDT)
Date: Sat, 26 Sep 2009 12:14:31 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] x86: SLUB: Remove unused CONFIG FAST_CMPXCHG_LOCAL
In-Reply-To: <1253981501.4568.61.camel@ht.satnam>
Message-ID: <alpine.DEB.1.10.0909261214040.16276@gentwo.org>
References: <1253981501.4568.61.camel@ht.satnam>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "Robert P. J. Day" <rpjday@crashcourse.ca>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Leftover stuff from a reverted patch.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

On Sat, 26 Sep 2009, Jaswinder Singh Rajput wrote:

>
> Remove unused CONFIG FAST_CMPXCHG_LOCAL from Kconfig and defconfigs
>
> Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@elte.hu>
> ---
>  arch/x86/Kconfig                  |    4 ----
>  arch/x86/configs/i386_defconfig   |    1 -
>  arch/x86/configs/x86_64_defconfig |    1 -
>  3 files changed, 0 insertions(+), 6 deletions(-)
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 9369879..27ebee4 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -86,10 +86,6 @@ config STACKTRACE_SUPPORT
>  config HAVE_LATENCYTOP_SUPPORT
>  	def_bool y
>
> -config FAST_CMPXCHG_LOCAL
> -	bool
> -	default y
> -
>  config MMU
>  	def_bool y
>
> diff --git a/arch/x86/configs/i386_defconfig b/arch/x86/configs/i386_defconfig
> index d28fad1..fdf15d3 100644
> --- a/arch/x86/configs/i386_defconfig
> +++ b/arch/x86/configs/i386_defconfig
> @@ -17,7 +17,6 @@ CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
>  CONFIG_LOCKDEP_SUPPORT=y
>  CONFIG_STACKTRACE_SUPPORT=y
>  CONFIG_HAVE_LATENCYTOP_SUPPORT=y
> -CONFIG_FAST_CMPXCHG_LOCAL=y
>  CONFIG_MMU=y
>  CONFIG_ZONE_DMA=y
>  CONFIG_GENERIC_ISA_DMA=y
> diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_defconfig
> index 6c86acd..b75aec8 100644
> --- a/arch/x86/configs/x86_64_defconfig
> +++ b/arch/x86/configs/x86_64_defconfig
> @@ -17,7 +17,6 @@ CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
>  CONFIG_LOCKDEP_SUPPORT=y
>  CONFIG_STACKTRACE_SUPPORT=y
>  CONFIG_HAVE_LATENCYTOP_SUPPORT=y
> -CONFIG_FAST_CMPXCHG_LOCAL=y
>  CONFIG_MMU=y
>  CONFIG_ZONE_DMA=y
>  CONFIG_GENERIC_ISA_DMA=y
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
