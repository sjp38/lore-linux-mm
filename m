Date: Wed, 12 Jan 2005 23:31:46 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC] Avoiding fragmentation through different allocator
Message-ID: <20050113073146.GB1226@holomorphy.com>
References: <Pine.LNX.4.58.0501122101420.13738@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0501122101420.13738@skynet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 12, 2005 at 09:09:24PM +0000, Mel Gorman wrote:
> So... What the patch does. Allocations are divided up into three different
> types of allocations;
> UserReclaimable - These are userspace pages that are easily reclaimable. Right
> 	now, I'm putting all allocations of GFP_USER and GFP_HIGHUSER as
> 	well as disk-buffer pages into this category. These pages are trivially
> 	reclaimed by writing the page out to swap or syncing with backing
> 	storage
> KernelReclaimable - These are pages allocated by the kernel that are easily
> 	reclaimed. This is stuff like inode caches, dcache, buffer_heads etc.
> 	These type of pages potentially could be reclaimed by dumping the
> 	caches and reaping the slabs (drastic, but you get the idea). We could
> 	also add pages into this category that are known to be only required
> 	for a short time like buffers used with DMA
> KernelNonReclaimable - These are pages that are allocated by the kernel that
> 	are not trivially reclaimed. For example, the memory allocated for a
> 	loaded module would be in this category. By default, allocations are
> 	considered to be of this type

I'd expect to do better with kernel/user discrimination only, having
address-ordering biases in opposite directions for each case.

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
