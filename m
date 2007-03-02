Message-ID: <45E842F6.5010105@redhat.com>
Date: Fri, 02 Mar 2007 10:29:58 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
In-Reply-To: <20070301160915.6da876c5.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> And I'd judge that per-container RSS limits are of considerably more value
> than antifrag (in fact per-container RSS might be a superset of antifrag,
> in the sense that per-container RSS and containers could be abused to fix
> the i-cant-get-any-hugepages problem, dunno).

The RSS bits really worry me, since it looks like they could
exacerbate the scalability problems that we are already running
into on very large memory systems.

Linux is *not* happy on 256GB systems.  Even on some 32GB systems
the swappiness setting *needs* to be tweaked before Linux will even
run in a reasonable way.

Pageout scanning needs to be more efficient, not less.  The RSS
bits are worrysome...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
