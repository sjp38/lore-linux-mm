Date: Sun, 29 Aug 2004 15:28:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on
 swap partition
Message-Id: <20040829152820.715d137d.akpm@osdl.org>
In-Reply-To: <20040829221757.GA5492@holomorphy.com>
References: <20040828144303.0ae2bebe.akpm@osdl.org>
	<20040828215411.GY5492@holomorphy.com>
	<20040828151349.00f742f4.akpm@osdl.org>
	<20040828222816.GZ5492@holomorphy.com>
	<20040829033031.01c5f78c.akpm@osdl.org>
	<20040829141526.GC10955@suse.de>
	<20040829141718.GD10955@suse.de>
	<20040829131824.1b39f2e8.akpm@osdl.org>
	<20040829203011.GA11878@suse.de>
	<20040829135917.3e8ffed8.akpm@osdl.org>
	<20040829221757.GA5492@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: axboe@suse.de, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
>  On Sun, Aug 29, 2004 at 01:59:17PM -0700, Andrew Morton wrote:
>  > The changlog wasn't that detailed ;)
>  > But yes, it's the large nr_requests which is tripping up swapout.  I'm
>  > assuming that when a process exits with its anonymous memory still under
>  > swap I/O we're forgetting to actually free the pages when the I/O
>  > completes.  So we end up with a ton of zero-ref swapcache pages on the LRU.
>  > I assume.   Something odd's happening, that's for sure.
> 
>  Maybe we need to be checking for this in end_swap_bio_write() or
>  rotate_reclaimable_page()?

Maybe.  I thought a get_page() in swap_writepage() and a put_page() in
end_swap_bio_write() would cause the page to be freed.  But not.  It needs
some actual real work done on it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
