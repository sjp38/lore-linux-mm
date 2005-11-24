Date: Thu, 24 Nov 2005 08:04:39 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Kernel BUG at mm/rmap.c:491
In-Reply-To: <200511232256.jANMuGg20547@unix-os.sc.intel.com>
Message-ID: <Pine.LNX.4.61.0511240754190.5688@goblin.wat.veritas.com>
References: <200511232256.jANMuGg20547@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Nov 2005, Chen, Kenneth W wrote:
> Has people seen this BUG_ON before?  On 2.6.15-rc2, x86-64.
> 
> Bad page state at free_hot_cold_page (in process 'sh', page ffff81000482dde8)
> flags:0x8000000000000000 mapping:0000000000000000 mapcount:1 count:0
> Bad page state at free_hot_cold_page (in process 'sh', page ffff8100049d0f78)
> flags:0x8000000000000000 mapping:0000000000000000 mapcount:1 count:0
> Bad page state at free_hot_cold_page (in process 'sh', page ffff8100049d0f40)
> flags:0x8000000000000004 mapping:0000000000000000 mapcount:1 count:0
> Kernel BUG at mm/swap.c:218
> Kernel BUG at mm/rmap.c:491

Neither mm/rmap.c (page_remove_rmap) nor mm/swap.c (put_page_testzero)
BUG is interesting in this case, they're just side-effects of trying to
recover from the preceding "Bad page state"s.

Which are interesting.  Not at all the same case as the many recently
reported while we were fixing up PageReserved removal cases; though
yours will probably be related.

It could conceivably be an effect of a DRM pci_alloc_consistent issue
which Dave Airlie spotted yesterday; but not a typical case of it,
and I'm probably only thinking of that one because it's uppermost.

Please send your .config (I hope it's tailored somewhat to your machine,
rather than an allyesconfig or the like?) and bootup dmesg, in case they
help to narrow the search.  You were just running straight 2.6.15-rc2,
no additional patches?  Doing anything interesting just before this
happened?

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
