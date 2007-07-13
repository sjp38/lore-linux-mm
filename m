Date: Fri, 13 Jul 2007 10:04:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
In-Reply-To: <exportbomb.1184333503@pinky>
Message-ID: <Pine.LNX.4.64.0707131001060.21777@schroedinger.engr.sgi.com>
References: <exportbomb.1184333503@pinky>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, Andy Whitcroft wrote:

> Andrew, please consider for -mm.
> 
> Note that I am away from my keyboard all of next week, but I figured
> it better to get this out for testing.

Yes grumble. Why does it take so long...

Would it be possible to merge this for 2.6.23 (maybe late?). This has been 
around for 6 months now. It removes the troubling lookups in 
virt_to_page and page_address in sparsemem that have spooked many of us. 

virt_to_page efficiency is a performance issue for kfree and 
kmem_cache_free in the slab allocators. I inserted probles and saw 
that the patchset cuts down the cycles spend in virt_to_page by 50%.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
