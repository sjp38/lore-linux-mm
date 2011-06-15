Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9E6356B004A
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:55:59 -0400 (EDT)
Subject: Re: [PATCH] slob: push the min alignment to long long
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <BANLkTi=QG3ywRhSx=npioJx-d=yyf=o29A@mail.gmail.com>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
	 <1308089140.15617.221.camel@calx>
	 <20110615201202.GB19593@Chamillionaire.breakpoint.cc>
	 <1308169466.15617.378.camel@calx>
	 <BANLkTi=QG3ywRhSx=npioJx-d=yyf=o29A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Jun 2011 15:55:55 -0500
Message-ID: <1308171355.15617.401.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org

On Wed, 2011-06-15 at 23:40 +0300, Pekka Enberg wrote:
> On Wed, Jun 15, 2011 at 11:24 PM, Matt Mackall <mpm@selenic.com> wrote:
> > On Wed, 2011-06-15 at 22:12 +0200, Sebastian Andrzej Siewior wrote:
> >> * Matt Mackall | 2011-06-14 17:05:40 [-0500]:
> >>
> >> >Ok, so you claim that ARCH_KMALLOC_MINALIGN is not set on some
> >> >architectures, and thus SLOB does the wrong thing.
> >> >
> >> >Doesn't that rather obviously mean that the affected architectures
> >> >should define ARCH_KMALLOC_MINALIGN? Because, well, they have an
> >> >"architecture-specific minimum kmalloc alignment"?
> >>
> >> nope, if nothing is defined SLOB asumes that alignment of long is the way
> >> go. Unfortunately alignment of u64 maybe larger than of u32.
> >
> > I understand that. I guess we have a different idea of what constitutes
> > "architecture-specific" and what constitutes "normal".
> >
> > But I guess I can be persuaded that most architectures now expect 64-bit
> > alignment of u64s.
> 
> Changing the alignment for everyone is likely to cause less problems
> in the future. Matt, are there any practical reasons why we shouldn't
> do that?

Unless you audit all architectures to check that things are sensible,
it's a trade: regressing performance on one arch to improve correctness
on another. On the one hand, regressions trump improvement. On the
other, correctness trumps performance.

In general, I think the right thing is to require every arch to
explicitly document its alignment requirements via defines in the kernel
headers so that random hackers don't have to scour the internet for
datasheets on obscure architectures they don't care about. We should
have no defaults and refuse to compile on any arch that doesn't have the
define which will ensure someone somewhere actually thinks about it for
each arch.

But as I don't have time to push that vision, I'll let it slide.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
