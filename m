Date: Fri, 6 Sep 2002 19:04:25 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: inactive_dirty list
In-Reply-To: <3D79250B.6D705166@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209061902120.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, Andrew Morton wrote:

> hum.  I'm trying to find a model where the VM can just ignore
> dirty|writeback pagecache.  We know how many pages are out
> there, sure.  But we don't scan them.  Possible?

Owww duh, I see it now.

So basically pages should _only_ go into the inactive_dirty list
when they are under writeout.

Note that leaving dirty pages on the list can result in a waste
of memory. Imagine the dirty limit being 40% and 30% of memory
being dirty but not written out at the moment ...

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
