Date: Fri, 6 Sep 2002 19:23:59 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: inactive_dirty list
In-Reply-To: <3D7929F7.7B19C9C@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209061923020.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, Andrew Morton wrote:

> > So basically pages should _only_ go into the inactive_dirty list
> > when they are under writeout.
>
> Or if they're just dirty.  The thing I'm trying to achieve
> is to minimise the amount of scanning of unreclaimable pages.
>
> So park them elsewhere, and don't scan them.  We know how many
> pages are there, so we can make decisions based on that.  But let
> IO completion bring them back onto the inactive_reclaimable(?)
> list.

I guess this means the dirty limit should be near 1% for the
VM.

Every time there is a noticable amount of dirty pages, kick
pdflush and have it write out a few of them, maybe the number
of pages needed to reach zone->pages_high ?

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
