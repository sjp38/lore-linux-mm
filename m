Date: Wed, 13 Nov 2002 19:33:48 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] 10/4  -ac to newer rmap
Message-ID: <20021113193348.A29582@infradead.org>
References: <20021113193041Z80262-23310+72@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021113193041Z80262-23310+72@imladris.surriel.com>; from riel@conectiva.com.br on Wed, Nov 13, 2002 at 05:30:34PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  /* 
>   * Wait for a page to get unlocked.
>   *
>   * This must be called with the caller "holding" the page,
>   * ie with increased "page->count" so that the page won't
>   * go away during the wait..
> - *
> - * The waiting strategy is to get on a waitqueue determined
> - * by hashing. Waiters will then collide, and the newly woken
> - * task must then determine whether it was woken for the page
> - * it really wanted, and go back to sleep on the waitqueue if
> - * that wasn't it. With the waitqueue semantics, it never leaves
> - * the waitqueue unless it calls, so the loop moves forward one
> - * iteration every time there is
> - * (1) a collision 
> - * and
> - * (2) one of the colliding pages is woken
> - *
> - * This is the thundering herd problem, but it is expected to
> - * be very rare due to the few pages that are actually being
> - * waited on at any given time and the quality of the hash function.
>   */

What is the pint of removing comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
