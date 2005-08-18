Date: Thu, 18 Aug 2005 09:04:41 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <20050817174359.0efc7a6a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0508180900410.25799@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, hugh@veritas.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Aug 2005, Andrew Morton wrote:

> d) the fact that some architectures will be using atomic pte ops and
>    others will be using page_table_lock in core MM code.

We could generally go to atomic pte operations. But this would 
require extensive changes to all architectures. There is a tradeoff 
between atomic operations and using regular loads and stores on page table 
entries. If a number of page table entries have to be modified then it is 
advantageous to take a lock. If an individial entry is modified then it is 
better to do an atomic operation.

>    Using different locking/atomicity schemes in different architectures
>    has obvious complexity and test coverage drawbacks.

We could require the same locking scheme for all architectures. Some 
architectures would then have to simulate the atomicity 
which would cause performance loss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
