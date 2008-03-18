Message-ID: <47E00FEF.10604@cs.helsinki.fi>
Date: Tue, 18 Mar 2008 20:54:39 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 7/9] slub: Adjust order boundaries and minimum objects
 per slab.
References: <20080317230516.078358225@sgi.com> <20080317230529.474353536@sgi.com>
In-Reply-To: <20080317230529.474353536@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, yanmin_zhang@linux.intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Since there is now no worry anymore about higher order allocs (hopefully).
> Set the max order to default to PAGE_ALLOC_ORDER_COSTLY (32k) and require
> slub to use a higher order if a certain object density cannot be reached.
> 
> The mininum objects per slab is calculated based on the number of processors
> that may come online.

Interesting. Why do we want to make min objects depend on CPU count and 
not amount of memory available on the system?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
