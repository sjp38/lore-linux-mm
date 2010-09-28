Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DD9326B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:41:45 -0400 (EDT)
Date: Tue, 28 Sep 2010 22:41:42 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: cleanup gfp_zone()
Message-ID: <20100928214141.GG19804@ZenIV.linux.org.uk>
References: <1285676624-1300-1-git-send-email-namhyung@gmail.com>
 <20100928143239.5fe34e1e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100928143239.5fe34e1e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2010 at 02:32:39PM -0700, Andrew Morton wrote:
> > +#define ZT_SHIFT(gfp) ((__force int) (gfp) * ZONES_SHIFT)
> >  #define GFP_ZONE_TABLE ( \
> > -	(ZONE_NORMAL << 0 * ZONES_SHIFT)				\
> > -	| (OPT_ZONE_DMA << __GFP_DMA * ZONES_SHIFT)			\
> > -	| (OPT_ZONE_HIGHMEM << __GFP_HIGHMEM * ZONES_SHIFT)		\
> > -	| (OPT_ZONE_DMA32 << __GFP_DMA32 * ZONES_SHIFT)			\
> > -	| (ZONE_NORMAL << __GFP_MOVABLE * ZONES_SHIFT)			\
> > -	| (OPT_ZONE_DMA << (__GFP_MOVABLE | __GFP_DMA) * ZONES_SHIFT)	\
> > -	| (ZONE_MOVABLE << (__GFP_MOVABLE | __GFP_HIGHMEM) * ZONES_SHIFT)\
> > -	| (OPT_ZONE_DMA32 << (__GFP_MOVABLE | __GFP_DMA32) * ZONES_SHIFT)\
> > +	(ZONE_NORMAL        << ZT_SHIFT(0))				\
> > +	| (OPT_ZONE_DMA     << ZT_SHIFT(__GFP_DMA))			\
> > +	| (OPT_ZONE_HIGHMEM << ZT_SHIFT(__GFP_HIGHMEM))			\
> > +	| (OPT_ZONE_DMA32   << ZT_SHIFT(__GFP_DMA32))			\
> > +	| (ZONE_NORMAL      << ZT_SHIFT(__GFP_MOVABLE))			\
> > +	| (OPT_ZONE_DMA     << ZT_SHIFT(__GFP_MOVABLE | __GFP_DMA))	\
> > +	| (ZONE_MOVABLE     << ZT_SHIFT(__GFP_MOVABLE | __GFP_HIGHMEM)) \
> > +	| (OPT_ZONE_DMA32   << ZT_SHIFT(__GFP_MOVABLE | __GFP_DMA32))	\
> >  )
> 
> hm.  I hope these sparse warnings are sufficiently useful to justify
> all the gunk we're adding to support them.
> 
> Is it actually finding any bugs?

FWIW, bitwise or done in the right-hand argumet of shift looks ugly as hell;
what the hell is that code _doing_?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
