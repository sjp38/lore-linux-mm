Date: Tue, 15 May 2001 12:31:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: on load control / process swapping
In-Reply-To: <3B00CECF.9A3DEEFA@mindspring.com>
Message-ID: <Pine.LNX.4.21.0105151219240.4671-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Terry Lambert <tlambert2@mindspring.com>
Cc: Matt Dillon <dillon@earth.backplane.com>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2001, Terry Lambert wrote:
> Rik van Riel wrote:
> > So we should not allow just one single large job to take all
> > of memory, but we should allow some small jobs in memory too.
> 
> Historically, this problem is solved with a "working set
> quota".

This is a great idea for when the system is in-between normal
loads and real thrashing. It will save small processes while
slowing down memory hogs which are taking resources fairly.

I'm not convinced it is any replacement for swapping, but it
sure a good way to delay swapping as long as possible.

Also, having a working set size guarantee in combination with
idle swapping will almost certainly give the proveribial root
shell the boost it needs ;)

> Doing extremely complicated things is only going to get
> you into trouble... in particular, you don't want to
> have policy in effect to deal with border load conditions
> unless you are under those conditions in the first place.

Agreed.

> It's possible to do a more complicated working set quota,
> which actually applies to a process' working set, instead
> of to vnodes, out of context with the process,

I guess in FreeBSD a per-vnode approach would be easier to
implement while in Linux a per-process working set would be
easier...

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
