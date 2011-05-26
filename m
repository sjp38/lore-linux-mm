Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A41736B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:28:26 -0400 (EDT)
Message-ID: <4DDEC473.3050701@zytor.com>
Date: Thu, 26 May 2011 14:21:55 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
References: <20110516202605.274023469@linux.com> <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com> <alpine.DEB.2.00.1105261315350.26578@router.home> <4DDE9C01.2090104@zytor.com> <alpine.DEB.2.00.1105261615130.591@router.home>
In-Reply-To: <alpine.DEB.2.00.1105261615130.591@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 05/26/2011 02:16 PM, Christoph Lameter wrote:
> Here is a new patch that may address the concerns. The list of cpus that
> support CMPXCHG_DOUBLE is not complete.Could someone help me complete it?

> Index: linux-2.6/arch/x86/Kconfig.cpu
> ===================================================================
> --- linux-2.6.orig/arch/x86/Kconfig.cpu	2011-05-26 16:03:33.625608967 -0500
> +++ linux-2.6/arch/x86/Kconfig.cpu	2011-05-26 16:13:22.795605197 -0500
> @@ -312,6 +312,16 @@ config X86_CMPXCHG
>  config CMPXCHG_LOCAL
>  	def_bool X86_64 || (X86_32 && !M386)
> 
> +#
> +# CMPXCHG_DOUBLE needs to be set to enable the kernel to use cmpxchg16/8b
> +# for cmpxchg_double if it find processor flags that indicate that the
> +# capabilities are available. CMPXCHG_DOUBLE only compiles in
> +# detection support. It needs to be set if there is a chance that processor
> +# supports these instructions.
> +#
> +config CMPXCHG_DOUBLE
> +	def_bool GENERIC_CPU || X86_GENERIC || M486 || MPENTIUM4 || MATOM || MCORE2
> +

How about:

X86_64 || X86_GENERIC || !M386

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
