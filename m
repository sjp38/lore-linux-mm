Date: Mon, 29 Jul 2002 23:29:14 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] vmap_pages() (4th resend)
Message-ID: <20020729232914.A6399@lst.de>
References: <20020729214638.A4582@lst.de> <Pine.LNX.4.33.0207291355550.1470-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0207291355550.1470-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Jul 29, 2002 at 01:59:29PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2002 at 01:59:29PM -0700, Linus Torvalds wrote:
> Hmm? Is that such a big deal? I think it's worth it for cleanliness, and
> kmalloc() should be plenty big enough (a standard 4kB kmalloc on x86 can
> cover 4MB worth of vmalloc() space, and anybody who wants to vmalloc more
> than than that had better have some good reason for it - and kmalloc() 
> does actually work for much larger areas too).
> 
> So the kmalloc() approach sounds pretty trivial to me.

Yes, it sounds trivial.  It just didn't get to my internal yuckiness
barrier.  I'll code it up anyway, it's not my kernel :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
