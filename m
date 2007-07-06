Date: Fri, 6 Jul 2007 13:48:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Style fix up the loop to disable small slabs
In-Reply-To: <20070706134043.e572eb7c.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707061345060.24851@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707061245120.24255@schroedinger.engr.sgi.com>
 <20070706134043.e572eb7c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007, Andrew Morton wrote:

> ugh, six slab patches, no sequence numbers.
> 
> What is the applying order?

Below the order in which they were sent. They should apply that 
way. The only dependencies AFAIK is that 4 depends on 3.

1. SLUB: Style fix up the loop to disable small slabs
2. SLUB: Do not use length parameter in slab_alloc()
3. Slab allocators: Cleanup zeroing allocations
4. Slab allocators: Replace explicit zeroing with __GF
5. SLUB: Do not allocate object bit array on stack
6. SLUB: Move sysfs operations outside of slub_lock
7. SLUB: Fix CONFIG_SLUB_DEBUG use for CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
