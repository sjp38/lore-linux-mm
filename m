Date: Mon, 12 Jun 2000 16:47:08 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Questions about page IO of swapping
In-Reply-To: <Pine.LNX.4.10.10005221323490.21738-100000@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.21.0006041615150.2482-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 May 2000, Ingo Oeser wrote:

>I thought encryption should be done before calling brw_page() in 
>mm/page_io.c:rw_swap_page_base()

only in the write case of course.

>and decryption in fs/buffer.c:after_unlock_page(), if the
>page->count is >0 after passing every other of the tests in this
>function.

If the page->count during swapping is zero then it's going to be a
bug. You shouldn't need to check the page count.

>So when is a page actually considered written to disk and when is
>it accessed first after this? 

Of course you have to encrypt on a kind of bounce page, not on the swap
cache. While decrypting you can decrypt in place instead.

>I have also problems tracking reads vs. writes, because this

I see. You can probably check if the page is uptodate or not to know if
it's a read or a write during disk completation.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
