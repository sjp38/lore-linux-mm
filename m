Date: Wed, 27 Oct 2004 19:08:16 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: news about IDE PIO HIGHMEM bug (was: Re: 2.6.9-mm1)
Message-ID: <20041027180816.GA32436@infradead.org>
References: <58cb370e041027074676750027@mail.gmail.com> <417FBB6D.90401@pobox.com> <1246230000.1098892359@[10.10.2.4]> <1246750000.1098892883@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246750000.1098892883@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "Randy.Dunlap" <rddunlap@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <axboe@suse.de>
List-ID: <linux-mm.kvack.org>

> To repeat what I said in IRC ... ;-)
> 
> Actually, you could check this with the pfns being the same when >> MAX_ORDER-1.
> We should be aligned on a MAX_ORDER boundary, I think.
> 
> However, pfn_to_page(page_to_pfn(page) + 1) might be safer. If rather slower.

I think this is the wrong level of interface exposed.  Just add two hepler
kmap_atomic_sg/kunmap_atomic_sg that gurantee to map/unmap a sg list entry,
even if it's bigger than a page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
