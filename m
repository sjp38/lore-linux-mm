Date: Wed, 17 Aug 2005 15:19:29 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <20050817151723.48c948c7.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0508171516570.19035@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Aug 2005, Andrew Morton wrote:

> a) general increase of complexity

The complexity is necesary in order to move to atomic operations that will 
also allow future enhancements.
 
> b) the fact that they only partially address the problem: anonymous page
>    faults are addressed, but lots of other places aren't.

The patches also allow atomic updates of pte flags. The most common 
bottleneck are anonymous faults.

> c) the fact that they address one particular part of one particular
>    workload on exceedingly rare machines.

No this is a general fix for anonymous page faults on SMP machines. As 
noted at the KS, other are seeing similar performance problems.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
