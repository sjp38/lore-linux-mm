Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 661EC6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 11:13:17 -0400 (EDT)
Date: Tue, 31 May 2011 10:13:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
In-Reply-To: <1306445159.2543.25.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1105311012420.18755@router.home>
References: <20110516202605.274023469@linux.com>  <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>  <alpine.DEB.2.00.1105261315350.26578@router.home>  <4DDE9C01.2090104@zytor.com>  <alpine.DEB.2.00.1105261615130.591@router.home>
 <1306445159.2543.25.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, 26 May 2011, Eric Dumazet wrote:

> > +#define cmpxchg16b(ptr, o1, o2, n1, n2)				\
> > +({								\
> > +	char __ret;						\
> > +	__typeof__(o2) __junk;					\
> > +	__typeof__(*(ptr)) __old1 = (o1);			\
> > +	__typeof__(o2) __old2 = (o2);				\
> > +	__typeof__(*(ptr)) __new1 = (n1);			\
> > +	__typeof__(o2) __new2 = (n2);				\
> > +	asm volatile(LOCK_PREFIX_HERE "lock; cmpxchg16b (%%rsi);setz %1" \
>
> If there is no emulation, why do you force rsi here ?
>
> It could be something else, like "=m" (*ptr) ?
>
> (same remark for other functions)

Well I ran into trouble with =m. Maybe +m will do. Will try again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
