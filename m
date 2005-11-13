From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
Date: Sun, 13 Nov 2005 12:22:48 +0100
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com> <200511110406.24838.ak@suse.de> <Pine.LNX.4.62.0511110934110.20360@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511110934110.20360@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511131222.48690.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Friday 11 November 2005 18:40, Christoph Lameter wrote:

> Hmm. Thats not easy to do since the slab allocator is managing the pages 
> in terms of the nodes where they are located. The whole thing is geared to 
> first inspect the lists for one node and then expand if no page is 
> available.

Yes, that's fine - as long as it doesn't allocate too many 
pages at one go (which it doesn't) then the interleaving should
even the allocations out at page level.

> The cacheline already in use by the page allocator, the page allocator 
> will continually reference current->mempolicy. See alloc_page_vma and 
> alloc_pages_current. So its likely that the cacheline is already active 
> and the impact on the hot code patch is likely negligible.

I don't think that's likely - frequent users of kmem_cache_alloc don't
call alloc_pages. That is why we have slow and fast paths for this ...
But if we keep adding all the features of slow paths to fast paths
then the fast paths will be eventually not be fast anymore.
 
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
