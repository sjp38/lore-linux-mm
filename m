Date: Wed, 23 Nov 2005 13:26:47 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
 conditions
Message-Id: <20051123132647.257710b9.akpm@osdl.org>
In-Reply-To: <1132779605.25086.69.camel@akash.sc.intel.com>
References: <20051122161000.A22430@unix-os.sc.intel.com>
	<Pine.LNX.4.62.0511231128090.22710@schroedinger.engr.sgi.com>
	<1132775194.25086.54.camel@akash.sc.intel.com>
	<20051123115545.69087adf.akpm@osdl.org>
	<1132779605.25086.69.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: clameter@engr.sgi.com, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rohit Seth <rohit.seth@intel.com> wrote:
>
> > I don't think Martin was able to demonstrate much benefit from the lock
> > contention reduction on 16-way NUMAQ either.
> > 
> > So I dithered for months and it was a marginal merge, so it's appropriate
> > to justify the continued presence of the code.
> > 
> 
> May be the limits on the number of pages hanging on the per_cpu_pagelist
> was (or even now is) too small (for them to give any meaningful gain).
> May be we should have more physical contiguity in each of these pcps to
> give better cache spread.  

Could be.  The initial settings were pretty arbitrary - I assumed that
someone would get in and tune them up, but nothing much happened.  Perhaps
we should expose the thresholds in /proc/sys/vm so they're easier to play
with.

> > We didn't measure for any coloring effects though.  In fact, I didn't know
> > that this feature actually provided any benefit in that area.  
> 
> I thought Nick et.al came up with some of the constant values like batch
> size to tackle the page coloring issue specifically.  In any case, I
> think one of the key difference between 2.4 and 2.6 allocators is the
> pcp list.  And even with the minuscule batch and high watermarks this is
> helping ordinary benchmarks (by reducing the variation from run to run).

OK, useful info, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
