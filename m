Date: Mon, 29 Jul 2002 21:46:38 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] vmap_pages() (4th resend)
Message-ID: <20020729214638.A4582@lst.de>
References: <20020729211558.A4299@lst.de> <Pine.LNX.4.33.0207291222440.11377-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0207291222440.11377-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Jul 29, 2002 at 12:25:24PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2002 at 12:25:24PM -0700, Linus Torvalds wrote:
> > The old vmalloc_area_pages is renamed to __vmap_area_pages and
> > vmalloc_area_pages is a small wrapper around it, passing in an NULL page
> > array.  Similarly __vmalloc is renamed to vmap_pages and a small wrapper
> > is added.
> 
> I don't like the NULL page array.
> 
> I think vmalloc() should just allocate the pages and create the page 
> array, and vmap_pages() should never check for NULL. Ok?

I looked into implementing your suggestion the last, but the problem is
that we need to pass in a page array.  To do so we could either allocate
all the pages as high-order allocation or kmalloc() the array where we
place the pages.  Both doesn't seem very practical to me..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
