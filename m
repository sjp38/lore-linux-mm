Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 214D86B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 10:13:19 -0400 (EDT)
Date: Wed, 1 Jun 2011 09:13:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
In-Reply-To: <4DE57FBB.8040408@zytor.com>
Message-ID: <alpine.DEB.2.00.1106010910430.22901@router.home>
References: <20110516202605.274023469@linux.com>  <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>  <alpine.DEB.2.00.1105261315350.26578@router.home>  <4DDE9C01.2090104@zytor.com>  <alpine.DEB.2.00.1105261615130.591@router.home>
 <1306445159.2543.25.camel@edumazet-laptop> <alpine.DEB.2.00.1105311012420.18755@router.home> <4DE50632.90906@zytor.com> <alpine.DEB.2.00.1105311058030.19928@router.home> <4DE576EA.6070906@zytor.com> <alpine.DEB.2.00.1105311846230.31190@router.home>
 <4DE57FBB.8040408@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Tue, 31 May 2011, H. Peter Anvin wrote:

> On 05/31/2011 04:49 PM, Christoph Lameter wrote:
> >>>
> >>> +#
> >>> +# CMPXCHG_DOUBLE needs to be set to enable the kernel to use cmpxchg16/8b
> >>> +# for cmpxchg_double if it find processor flags that indicate that the
> >>> +# capabilities are available. CMPXCHG_DOUBLE only compiles in
> >>> +# detection support. It needs to be set if there is a chance that processor
> >>> +# supports these instructions.
> >>> +#
> >>> +config CMPXCHG_DOUBLE
> >>> +	def_bool GENERIC_CPU || X86_GENERIC || !M386
> >>> +
> >>>  config X86_L1_CACHE_SHIFT
> >>>  	int
> >>>  	default "7" if MPENTIUM4 || MPSC
> >>
> >> Per previous discussion:
> >>
> >> - Drop this Kconfig option (it is irrelevant.)  CONFIG_CMPXCHG_LOCAL is
> >> different: it indicates that CMPXCHG is *guaranteed* to exist.
> >
> > Right but this is for cmpxchg16b which means that we need to check a
> > bit in the processor flags. Isnt this what you suggested?
> >
>
> Per your own description:
>
> "CMPXCHG_DOUBLE only compiles in detection support. It needs to be set
> if there is a chance that processor supports these instructions."
>
> That condition is always TRUE, so no Kconfig is needed.

There are several early processors (especially from AMD it seems) that do
not support cmpxchg16b. If one builds a kernel specifically for the early
cpus then the support does not need to be enabled.

This is also an issue going beyond x86. Other platforms mostly do not
support double word cmpxchg so the code for this feature also does not
need to be included for those builds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
