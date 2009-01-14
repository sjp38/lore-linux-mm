Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A0A0C6B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 13:01:47 -0500 (EST)
Date: Wed, 14 Jan 2009 12:01:32 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090114150900.GC25401@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0901141158090.26507@quilx.com>
References: <20090114090449.GE2942@wotan.suse.de>
 <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
 <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
 <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
 <20090114150900.GC25401@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jan 2009, Nick Piggin wrote:

> Right, but that regression isn't my only problem with SLUB. I think
> higher order allocations could be much more damaging for more a wider
> class of users. It is less common to see higher order allocation failure
> reports in places other than lkml, where people tend to have systems
> stay up longer and/or do a wider range of things with them.

The higher orders can fail and will then result in the allocator doing
order 0 allocs. It is not a failure condition. Higher orders are an
advantage because they localize variables of the same type and therefore
reduce TLB pressure.

> The idea of removing queues doesn't seem so good to me. Queues are good.
> You amortize or avoid all sorts of things with queues. We have them
> everywhere in the kernel ;)

Queues require maintenance which introduces variability because queue
cleaning has to be done periodically and the queues grow in number if NUMA
scenarios have to be handled effectively. This is a big problem for low
latency applications (like in HPC). Spending far too much time optimizing
queue cleaning in SLAB lead to the SLUB idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
