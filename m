Date: Mon, 23 Oct 2000 15:02:06 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Another wish item for your TODO list...
In-Reply-To: <20001023175402.B2772@redhat.com>
Message-ID: <Pine.LNX.4.21.0010231501210.13115-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Oct 2000, Stephen C. Tweedie wrote:

> Just a quick thought --- at some point it would be good if we
> could add logic to the core VM so that for sequentially accessed
> files, reclaiming any page of the file from cache would evict
> the _whole_ of the file from cache.

I take it you mean "move all the pages from before the
currently read page to the inactive list", so we preserve
the pages we just read in with readahead ?

> For large files, we're not going to try to cache the whole thing
> anyway.  For small files, reading the whole file back in later
> isn't much more expensive than reading back a few fragments if
> the rest still happens to be in cache.

Indeed.

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
