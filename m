Date: Mon, 2 Oct 2000 20:06:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.10.10010021550080.2206-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010022002440.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Linus Torvalds wrote:
> On Mon, 2 Oct 2000, Rik van Riel wrote:
> > 
> > Yes it has. The write order in flush_dirty_buffers() is the order
> > in which the pages were written. This may be different from the
> > LRU order and could give us slightly better IO performance.
> 
> .. or it might not.
> 
> Basically, the LRU order will be the same, EXCEPT if you have
> people re-writing.
> 
> And if you have re-writing going on, you can't really say which
> order is better.

Agreed.

> > Furthermore, we'll need to preserve the data writeback list,
> > since you really want to write back old data to disk some
> > time.
> 
> Aging will certainly take care of that. As long as you do the
> writeback _before_ you age it.

Ummm. Even if you don't have any memory pressure, you'll
still want old data to be written to disk. Currently all
data which is written is committed to disk after 5 seconds
by default.

I wouldn't want to lose this piece of functionality ;)

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
