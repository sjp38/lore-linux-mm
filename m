Date: Thu, 8 Nov 2007 11:00:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 12/23] SLUB: Trigger defragmentation from memory reclaim
In-Reply-To: <20071108151249.GE2591@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711081059420.8954@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011229.423714790@sgi.com>
 <20071108151249.GE2591@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007, Mel Gorman wrote:

> >  	up_read(&shrinker_rwsem);
> > +	if (gfp_mask & __GFP_FS)
> > +		kmem_cache_defrag(zone ? zone_to_nid(zone) : -1);
> 
> Does this make an assumption that only filesystem-related slabs may be
> targetted for reclaim? What if there is a slab that can free its objects
> without ever caring about a filesystem?

Correct. Currently only filesystem related slabs support slab defragy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
