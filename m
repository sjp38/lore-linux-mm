Date: Wed, 5 May 2004 16:14:16 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.6-rc3-mm1
Message-ID: <20040505161416.A4008@infradead.org>
References: <20040430014658.112a6181.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040430014658.112a6181.akpm@osdl.org>; from akpm@osdl.org on Fri, Apr 30, 2004 at 01:46:58AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, hugh@veritas.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 30, 2004 at 01:46:58AM -0700, Andrew Morton wrote:
> +rmap-14-i_shared_lock-fixes.patch
> +rmap-15-vma_adjust.patch
> +rmap-16-pretend-prio_tree.patch
> +rmap-17-real-prio_tree.patch
> +rmap-18-i_mmap_nonlinear.patch
> +rmap-19-arch-prio_tree.patch
> 
>  More VM work from Hugh

That's about 600 lines of additional code.  And that prio tree code is
used a lot, so even worse for that caches.

Do we have some benchmarks of real-life situation where the prio trees
show a big enough improvement or some 'exploits' where the linear list
walking leads to DoS situtations?

The bases objrmap/anonrmap changes keep the LOC pretty much the same as
the old pte-chain based code, but this is really a whole lot of code bloating
up the kernel and I'd prefer to see some numbers before it's going in..
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
