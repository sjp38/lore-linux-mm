Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
References: <Pine.LNX.4.21.0006071025330.14304-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 07 Jun 2000 16:29:15 +0200
In-Reply-To: Rik van Riel's message of "Wed, 7 Jun 2000 10:39:13 -0300 (BRST)"
Message-ID: <qww7lc1pnt0.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:
> Basically we need 2 things from the shm code, then I'll
> be able to adapt shrink_mmap with a few minutes of work ;)
> 
> 1) shm pages should be marked as such so we can recognise them

O.K. this is trivial.

> 2) we need to be able to swap out shm pages (maybe just
>    call a page->mapping->swapout() function?) by knowing just
>    the page

This is not that easy. I need a backreference to the shm segment and
the index into it to be able to note the new pte entry. Do you know
where we could put these?

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
