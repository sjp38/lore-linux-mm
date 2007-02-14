Date: Wed, 14 Feb 2007 14:41:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Use ZVC counters to establish exact size of dirtyable pages
In-Reply-To: <20070214142432.a7e913fa.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702141433190.3228@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
 <20070213000411.a6d76e0c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
 <20070214142432.a7e913fa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007, Andrew Morton wrote:

> Suppose a zone has ten dirty pages.  All the remaining pages in the zone
> are off being used for soundcard buffers and networking skbs.

Thats a pretty artificial situation.There is a min_free_kbytes that 
should give us some safety there. Only GFP_ATOMIC could get us there.

> This function will return zero.  Which I think we'll happen to handle OK.

One would expect the function to return 10. The 10 pages are on the LRU.
If we really have zero dirtyable pages then we will get a division by 
zero problem.

> But this function can, I think, also return negative (ie: very large)
> numbers.  I don't think we handle that right.

How would that occur? The only way that I could think this would happen is 
if for some strange reason the highmem counts are bigger than the total 
counts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
