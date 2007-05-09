Date: Wed, 9 May 2007 11:25:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Reduce antifrag max order
In-Reply-To: <Pine.LNX.4.64.0705081411440.20563@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705091123530.28965@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705050925350.27136@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705081411440.20563@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 May 2007, Mel Gorman wrote:

> Anti-frag still depends on reclaim to take place and I imagine you have not
> altered min_free_kbytes to keep pages free. Also, I don't think kswapd is
> currently making any effort to keep blocks free at a known desired order
> although I'm cc'ing Andy Whitcroft to confirm. As the kernel gives up easily
> when order > PAGE_ALLOC_COSTLY_ORDER, prehaps you should be using
> PAGE_ALLOC_COSTLY_ORDER instead of DEFAULT_ANTIFRAG_MAX_ORDER for SLUB.

One other interesting item: I accidentally left a machine running with 
slub_min_order=6 (1G UP x86_64). It ran for at least a day while I 
prepped mm patches on it. Failed today when I tried to untar a kernel 
tarball.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
