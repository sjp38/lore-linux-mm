Date: Mon, 16 Aug 1999 19:19:46 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <19990816184848.F14973@mencheca.ch.genedata.com>
Message-ID: <Pine.LNX.4.10.9908161859440.3016-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <Matthew.Wilcox@genedata.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, Matthew Wilcox wrote:

>Have you got some lmbench results to back this up?

Does lmbench benchmark the _allocation_ of the memory? If so could you
point out to me the exact lmbench command? (you would save me the time for
writing such a simple bench ;). I looked a bit at lmbench and it seems to
me that all mm tools are measuring the time _after_ the allocation
happened (so measuring the hardware bus/cache speed or page-colouring
algorithms and not the OS anonymous/shm page-fault time). But maybe I am
overlooking something?

All bw_mem_rw/bw_mem_cp/bw_mem_rd are _useless_ to benchmark the bigmem
patch since as just said once the allocation of memory is completed the
performance decrease will be _zero_ and not only close to zero.

The only tiny performance hit will happens while allocating a page for
clearing it or for doing the COW inside the page-fault handler (if you
are going to benchmark it make sure to #undef KMAP_DEBUG).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
