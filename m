Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E81D26B0083
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 05:13:36 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <87hc3qcpo1.fsf@basil.nowhere.org>
References: <20090121143008.GV24891@wotan.suse.de>
	 <87hc3qcpo1.fsf@basil.nowhere.org>
Date: Fri, 23 Jan 2009 12:13:32 +0200
Message-Id: <1232705612.6094.38.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Hi Andi,

On Fri, 2009-01-23 at 10:55 +0100, Andi Kleen wrote:
> > +#if L1_CACHE_BYTES < 64
> > +	if (size > 64 && size <= 96)
> > +		return 1;
> > +#endif
> > +#if L1_CACHE_BYTES < 128
> > +	if (size > 128 && size <= 192)
> > +		return 2;
> > +#endif
> > +	if (size <=	  8) return 3;
> > +	if (size <=	 16) return 4;
> > +	if (size <=	 32) return 5;
> > +	if (size <=	 64) return 6;
> > +	if (size <=	128) return 7;
> > +	if (size <=	256) return 8;
> > +	if (size <=	512) return 9;
> > +	if (size <=       1024) return 10;
> > +	if (size <=   2 * 1024) return 11;
> > +	if (size <=   4 * 1024) return 12;
> > +	if (size <=   8 * 1024) return 13;
> > +	if (size <=  16 * 1024) return 14;
> > +	if (size <=  32 * 1024) return 15;
> > +	if (size <=  64 * 1024) return 16;
> > +	if (size <= 128 * 1024) return 17;
> > +	if (size <= 256 * 1024) return 18;
> > +	if (size <= 512 * 1024) return 19;
> > +	if (size <= 1024 * 1024) return 20;
> > +	if (size <=  2 * 1024 * 1024) return 21;
> 
> Have you looked into other binsizes?  iirc the original slab paper
> mentioned that power of two is usually not the best.

Judging by the limited boot-time testing I've done with kmemtrace, the
bulk of kmalloc() allocations are under 64 bytes or so and actually a
pretty ok fit with the current sizes. The badly fitting objects are
usually very big and of different sizes (so they won't share a cache
easily) so I'm not expecting big gains from non-power of two sizes.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
