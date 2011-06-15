Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0A96B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 18:53:45 -0400 (EDT)
Subject: Re: [PATCH] slob: push the min alignment to long long
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20110615.181148.650483947691740732.davem@davemloft.net>
References: <1308169466.15617.378.camel@calx>
	 <BANLkTi=QG3ywRhSx=npioJx-d=yyf=o29A@mail.gmail.com>
	 <1308171355.15617.401.camel@calx>
	 <20110615.181148.650483947691740732.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Jun 2011 17:53:40 -0500
Message-ID: <1308178420.15617.447.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: penberg@kernel.org, sebastian@breakpoint.cc, cl@linux-foundation.org, linux-mm@kvack.org, netfilter@vger.kernel.org

On Wed, 2011-06-15 at 18:11 -0400, David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Wed, 15 Jun 2011 15:55:55 -0500
> 
> > In general, I think the right thing is to require every arch to
> > explicitly document its alignment requirements via defines in the kernel
> > headers so that random hackers don't have to scour the internet for
> > datasheets on obscure architectures they don't care about.
> 
> Blink... because the compiler doesn't provide a portable way to
> do this, right? :-)

Because I, on x86, cannot deduce the alignment requirements of, say,
CRIS without doing significant research. So answering a question like
"are there any architectures where assumption X fails" is obnoxiously
hard, rather than being a grep.

I also don't think it's a given there's a portable way to deduce the
alignment requirements due to the existence of arch-specific quirks. If
an arch wants to kmalloc its weird crypto or SIMD context and those want
128-bit alignment, we're not going to want to embed that knowledge in
the generic code, but instead tweak an arch define.

Also note that not having generic defaults forces each new architectures
to (nominally) examine each assumption rather than discover they
inherited an incorrect default somewhere down the road.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
