Date: Wed, 4 Apr 2001 10:29:02 -0400 (EDT)
From: Richard Jerrell <jerrell@missioncriticallinux.com>
Subject: Re: [PATCH] Reclaim orphaned swap pages 
In-Reply-To: <Pine.LNX.4.21.0104031910450.7175-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0104041025050.12558-100000@jerrell.lowell.mclinux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Szabolcs Szakacsits <szaka@f-secure.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> But you should not count _all_ swapcache pages as freeable. 

I see what you mean now.  But still, swapcache pages are freeable.  If it
is still in the swapcache, then we still have space reserved on disk for
it.  If your page is being referenced by pte's, then eventually the
swapper will replace those pte's with a reference to the swap cell.  Then,
the swap cache page will be written to disk and reclaimed.  The pages are
not immediately freeable without any additional work, but they are there
because the page is able to be swapped out.  If you are trying to say we
can't count them because we don't know how much work it would take to free
that particular page, then why do we include buffermem pages in the total
of available memory.  We can't be guaranteed that those pages are
freeable, because block_flushpage might just leave them sitting around as
anonymous.  So, basically, I include the swap cache pages in the total
amount of free memory because they are taking up twice as much space as
they should be: one page on disk and one page in memory.

Rich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
