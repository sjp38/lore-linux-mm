Date: Wed, 23 May 2007 16:14:20 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070523211420.GJ11115@waste.org>
References: <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de> <Pine.LNX.4.64.0705222326260.16694@schroedinger.engr.sgi.com> <20070523071200.GB9449@wotan.suse.de> <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com> <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com> <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0705231314180.21665@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231314180.21665@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 01:16:06PM -0700, Christoph Lameter wrote:
> Oh. And I forgot to check mm.
> 
> See swap_prefetch.c:prefetch_suitable

Doesn't look problematic to me. Or if it is, it'll die for any system
that happens to use get_free_page a lot.

> I do not think the updating of these counters is optional. Their use will 
> increase as we get more sophisticated in balancing the VM load. We cannot 
> have developers do an #ifdef CONFIG_SLOB around ZVC use.

How does the VM deal with balancing users of get_free_page?

We can probably add a couple lines to dummy up NR_SLAB_UNRECLAIMABLE, but I
think the claim that SLOB is "broken" without it is completely overblown.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
