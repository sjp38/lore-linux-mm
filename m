Subject: Re: [PATCH next 2/3] slub defrag: dma_kmalloc_cache add_tail
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <Pine.LNX.4.64.0810050325440.22004@blonde.site>
References: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
	 <Pine.LNX.4.64.0810050325440.22004@blonde.site>
Date: Mon, 06 Oct 2008 10:46:47 +0300
Message-Id: <1223279207.30581.2.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2008-10-05 at 03:27 +0100, Hugh Dickins wrote:
> Why did that slowdown from mispinned pages manifest only on the G5?
> 
> Because something in my x86_32 and x86_64 configs (CONFIG_BLK_DEV_SR
> I believe) is giving me a kmalloc_dma-512 cache, and dma_kmalloc_cache()
> had not been updated to satisfy the assumption in kmem_cache_defrag(),
> that defragmentable caches come first in the list.
> 
> So, any DMAable cache was preventing all slub defragmentation: which
> looks like it's not been getting the testing exposure it deserves.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
