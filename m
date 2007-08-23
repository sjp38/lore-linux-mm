Date: Thu, 23 Aug 2007 14:08:28 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
Message-ID: <20070823120819.GO13915@v2.random>
References: <20070820215040.937296148@sgi.com> <1187692586.6114.211.camel@twins> <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com> <1187730812.5463.12.camel@lappy> <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com> <1187734144.5463.35.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187734144.5463.35.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 22, 2007 at 12:09:03AM +0200, Peter Zijlstra wrote:
> Strictly speaking:
> 
> if:
> 
>  page = alloc_page(gfp);
> 
> fails but:
> 
>  obj = kmem_cache_alloc(s, gfp);
> 
> succeeds then its a bug.

Why? this is like saying that if alloc_pages(order=1) fails but
alloc_pages(order=0) succeeds then it's a bug. Obviously it's not a
bug.

The only bug is if slab allocations <=4k fails despite
alloc_pages(order=0) would succeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
