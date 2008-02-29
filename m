Message-ID: <47C7BFFA.9010402@cs.helsinki.fi>
Date: Fri, 29 Feb 2008 10:19:06 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 6/8] slub: Adjust order boundaries and minimum objects
 per slab.
References: <20080229044803.482012397@sgi.com> <20080229044819.800974712@sgi.com>
In-Reply-To: <20080229044819.800974712@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Since there is now no worry anymore about higher order allocs (hopefully)
> increase the minimum of objects per slab to 60 so that slub can reach a
> similar fastpath/slowpath ratio as slab. Set the max order to default to
> 4 (64k) and require slub to use a higher order if a certain object density
> cannot be reached.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

I can see why you want to change the defaults for big iron but why not 
keep the existing PAGE_SHIFT check which leaves embedded and regular 
desktop unchanged?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
