Date: Fri, 15 Sep 2000 19:04:36 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] VM patch for 2.4.0-test8
In-Reply-To: <20000915213726.A9965@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0009151902530.1075-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Martin Josefsson <gandalf@wlug.westbo.se>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2000, Jamie Lokier wrote:
> Martin Josefsson wrote:
> > I've been trying to get my machine to swap but that seems hard with this
> > new patch :) I have 0kB of swap used after 8h uptime, and I have been
> > compiling, moving files between partitions and running md5sum on files
> > (that was a big problem before, everything ended up on the active list and
> > the swapping started and brought my machine down to a crawl)
> 
> No preemptive page-outs?

Yes. The system tries to keep about 1 second worth of
allocations on the inactive list (+ freepages.high).

If you're allocating lots of memory very fast, the
system /will/ try to swap out things beforehand...

> 0kB swap means if you suddenly need a lot of memory, inactive
> application pages have to be written to disk first.  There are
> always inactive application pages.

Indeed there are, but since we don't do physical page
based scanning yet, we don't deactivate pages from the
RSS of processes in the background yet ...

(that's a 2.5 issue)

> Maybe the stats are inaccurate.

Nope. The stats are just fine ;)

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
