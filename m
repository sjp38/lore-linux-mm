From: David Woodhouse <dwmw2@infradead.org>
Subject: kmap_kiobuf()
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Wed, 28 Jun 2000 16:41:55 +0100
Message-ID: <11270.962206915@cygnus.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: sct@redhat.com, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

I think it would be useful to provide a function which can be used to 
obtain a virtually-contiguous VM mapping of the pages of an iobuf.

Currently, to access the pages of an iobuf, you have to kmap() each page
individually. For various purposes, it would be useful to be able to kmap the
whole iobuf contiguously, so that you can guarantee that:

	page_address(iobuf->maplist[n]) + PAGE_SIZE 
		== page_address(iobuf->maplist[n+1])

    (for n such that n < iobuf->nr_pages, obviously. Don't be so pedantic.)

Rather than taking a kiobuf as an argument, the new function might as well 
be more generic:

unsigned long kremap_pages(struct page **maplist, int nr_pages);
void kunmap_pages(struct page **maplist, int nr_pages);

I had a quick look at the code for kmap() and vmalloc() and decided that 
even if I attempted to do it myself, I'd probably bugger it up and a MM 
hacker would have to fix it anyway. So I'm not going to bother.

T'would be useful if someone else could find the time to do so, though.


--
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
