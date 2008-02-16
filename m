Subject: Re: [patch 7/8] slub: Adjust order boundaries and minimum objects
	per slab.
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <Pine.LNX.4.64.0802161059420.25573@schroedinger.engr.sgi.com>
References: <20080215230811.635628223@sgi.com>
	 <20080215230854.643455255@sgi.com> <47B6A928.7000309@cs.helsinki.fi>
	 <Pine.LNX.4.64.0802161059420.25573@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Sat, 16 Feb 2008 14:20:59 -0600
Message-Id: <1203193259.6324.12.camel@cinder.waste.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2008-02-16 at 11:00 -0800, Christoph Lameter wrote:
> On Sat, 16 Feb 2008, Pekka Enberg wrote:
> 
> > These look quite excessive from memory usage point of view. I saw you dropping
> > DEFAULT_MAX_ORDER to 4 but it seems a lot for embedded guys, at least?
> 
> What would be a good max order then? 4 means we can allocate a 64k segment 
> for 16 4k objects.

Why are 4k objects even going through SLUB?

What happens if we have 8k free and try to allocate one 4k object
through SLUB?

Using an order greater than 0 is generally frowned upon. Kernels can and
do get into situations where they can't find two contiguous pages, which
is why we've gone to so much trouble on x86 to fit into a single page of
stack.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
