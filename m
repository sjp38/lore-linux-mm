Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BC0196B004A
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 13:41:29 -0400 (EDT)
Date: Fri, 8 Jul 2011 12:41:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <m2box5cplq.fsf@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1107081240010.23187@router.home>
References: <alpine.DEB.2.00.1107071314320.21719@router.home> <1310064771.21902.55.camel@jaguar> <alpine.DEB.2.00.1107071402490.24248@router.home> <20110707.122151.314840355798805828.davem@davemloft.net> <CAOJsxLFsX3Q84QAeyRt5dZOdRxb3TiABPrP-YrWc91+BmR8ZBg@mail.gmail.com>
 <alpine.DEB.2.00.1107071511010.26083@router.home> <m2box5cplq.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Miller <davem@davemloft.net>, marcin.slusarz@gmail.com, mpm@selenic.com, linux-kernel@vger.kernel.org, rientjes@google.com, linux-mm@kvack.org

On Thu, 7 Jul 2011, Andi Kleen wrote:

> Christoph Lameter <cl@linux.com> writes:
>
>
> > +#ifdef __HAVE_ARCH_INV_MEMSCAN
> > +void *inv_memscan(void *addr, int c, size_t size)
> > +{
> > +	if (!size)
> > +		return addr;
> > +	asm volatile("repz; scasb\n\t"
>
> This will just do the slow byte accesses again internally.
> scasb is not normally very optimized in microcode as far
> as I know.
>
> Also rep has quite some startup overhead which makes
> it a bad idea for small sizes (<16-20 or so)
>
> I would stay with the C version. I bet that one is
> faster.

If the c code is such an improvement then memscan and other
implementations can be accellerated in the same way. That would be useful
in general. We can get rid of the implementation for memscan and friends
in x86 arch code.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
