Date: Sun, 6 May 2001 18:03:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: accounting bh->b_count in page->count
In-Reply-To: <200105062036.QAA20511@datafoundation.com>
Message-ID: <Pine.LNX.4.21.0105061802330.582-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Zhuravlev <alexey@datafoundation.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 May 2001, Alexey Zhuravlev wrote:

> why do not change bh->b_page->count on getblk/brelse?
> this could prevent situation when a page that can't be
> freed by try_to_free_buffers from buffercache lives on
> inactive_dirty list and VM try to free it every time...

We have to watch out for one thing though ... we have
to be able to write inactive_dirty pages to disk without
having them move back to the active list ;)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
