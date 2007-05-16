Date: Wed, 16 May 2007 13:42:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Fix page allocation flags in grow_dev_page()
In-Reply-To: <20070516133416.9d730d08.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705161342110.11234@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705152111380.5192@schroedinger.engr.sgi.com>
 <20070516133416.9d730d08.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hugh@veritas.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, Andrew Morton wrote:

> erk.  When I fixed this up against Mel's stuff I ended up with:
> 
>         page = find_or_create_page(inode->i_mapping, index,
>                 (mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS) |
>                         __GFP_RECLAIMABLE);
> 
> static inline int allocflags_to_migratetype(gfp_t gfp_flags)
> {
> 	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> 
> so I assume that mapping_gfp_mask() already had __GFP_MOVABLE set.
> 
> 
> So... which is it to be?
> 

Yup. This was already reported during my review to Mel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
