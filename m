Date: Mon, 2 Oct 2000 18:23:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.10.10010021417200.826-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010021821210.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Linus Torvalds wrote:

> So if we have "lots" of memory, we basically optimize for speed
> (leave the cached mapping around), while if we get low on memory
> we automatically optimize for space (get rid of bh's when we
> don't know that we'll need them).

OK, so we want something like the following in
refill_inactive_scan() ?

if (free_shortage() && inactive_shortage() && page->mapping &&
			page->buffers)
	try_to_free_buffers(page, 0);

This would keep the buffer heads around in the background page
scans too and only free them when we really need to.

(but still, I'm not sure if this is agressive enough or not
quite agressive enough)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
