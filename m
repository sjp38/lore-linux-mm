Date: Mon, 29 Jul 2002 13:59:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] vmap_pages() (4th resend)
In-Reply-To: <20020729214638.A4582@lst.de>
Message-ID: <Pine.LNX.4.33.0207291355550.1470-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jul 2002, Christoph Hellwig wrote:
> 
> I looked into implementing your suggestion the last, but the problem is
> that we need to pass in a page array.  To do so we could either allocate
> all the pages as high-order allocation or kmalloc() the array where we
> place the pages.  Both doesn't seem very practical to me..

Hmm? Is that such a big deal? I think it's worth it for cleanliness, and
kmalloc() should be plenty big enough (a standard 4kB kmalloc on x86 can
cover 4MB worth of vmalloc() space, and anybody who wants to vmalloc more
than than that had better have some good reason for it - and kmalloc() 
does actually work for much larger areas too).

So the kmalloc() approach sounds pretty trivial to me.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
