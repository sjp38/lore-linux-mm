Date: Fri, 14 Jul 2000 10:35:00 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: writeback list
In-Reply-To: <20000714103535.H3113@redhat.com>
Message-ID: <Pine.LNX.4.21.0007141026340.10193-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jul 2000, Stephen C. Tweedie wrote:
> On Thu, Jul 13, 2000 at 04:30:35PM -0300, Rik van Riel wrote:
> > 
> > we may have forgotten something in our new new vm design from
> > last weekend. While we have the list head available to put
> > pages in the writeback list, we don't have an entry in to put
> > the timestamp of the write in struct_page...
> 
> It shouldn't matter.  Just assume something like the 30-second sync.
> You can keep placeholders in the list for that, or even do something
> like have multiple lists, one for the current 30-seconds being synced,
> one for the next sync.  You can do the same for 5-second metadata
> syncs too if you want;

Placeholders seem like the best idea to me. Having separate
lists for data and metadata will have to go away anyway when
we start using journaled filesystems (which have their own
ordering issues).

> It perturbs the LRU a bit, but then we also have page aging so
> that's not too bad.  (Are you planning on using the age values
> in the inactive list, btw?)

All pages on the inactive list will have age 0, once they are
touched they go back to the active list...

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
