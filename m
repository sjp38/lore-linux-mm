Date: Mon, 29 Jul 2002 12:25:24 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] vmap_pages() (4th resend)
In-Reply-To: <20020729211558.A4299@lst.de>
Message-ID: <Pine.LNX.4.33.0207291222440.11377-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jul 2002, Christoph Hellwig wrote:
> 
> The old vmalloc_area_pages is renamed to __vmap_area_pages and
> vmalloc_area_pages is a small wrapper around it, passing in an NULL page
> array.  Similarly __vmalloc is renamed to vmap_pages and a small wrapper
> is added.

I don't like the NULL page array.

I think vmalloc() should just allocate the pages and create the page 
array, and vmap_pages() should never check for NULL. Ok?

That way, you can also get rid of passing in the gfp_mask, since that is 
now entirely in the callers.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
