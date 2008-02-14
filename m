Date: Thu, 14 Feb 2008 12:32:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
In-Reply-To: <20080214202530.GD30841@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0802141231180.1507@schroedinger.engr.sgi.com>
References: <20080214040245.915842795@sgi.com> <20080214040314.118141086@sgi.com>
 <20080214141442.GF17641@csn.ul.ie> <Pine.LNX.4.64.0802141110280.32613@schroedinger.engr.sgi.com>
 <20080214200849.GB30841@csn.ul.ie> <Pine.LNX.4.64.0802141209470.1041@schroedinger.engr.sgi.com>
 <20080214202530.GD30841@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Mel Gorman wrote:

> > Hmmmm... Okay if pages are managed in pageblock_size chunks that are of 
> > HUGE_PAGE_SIZE then this patch makes no difference whatsoever.
> > 
> 
> Yes it does - it means that slub pages can be allocated from the movablecore=
> partition if slub_min_order is set to a magic value. What it does not do at
> all is help SLUB in a meaningful fashion.

No one that I know of is using this esoteric option. Did not even think 
about it when writing the patch.

> Still NACK.

Well its useless then. I will drop it then.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
