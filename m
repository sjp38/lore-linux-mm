Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 97C4716B68
	for <linux-mm@kvack.org>; Fri,  6 Apr 2001 16:06:14 -0300 (EST)
Date: Fri, 6 Apr 2001 16:06:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.31.0104061153350.12081-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33.0104061603240.7624-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Apr 2001, Linus Torvalds wrote:
> On Fri, 6 Apr 2001, Hugh Dickins wrote:
> >
> > It is, of course, remotely conceivable that I'm confused, but...
> > I realize that the page cache pages (including those of swap)
> > are already added into "free" by vm_enough_memory().  But it's also
> > adding in nr_swap_pages
>
> .. Ahh. Right you are. We did not just move it from the "free
> page" to the "swap cache", we also didn't release the space in
> the actual swap space bitmaps, and you're right, that certainly
> changes the accounting.

>From all swap space, the following is available (in principle):
  - free swap
  - swapcached space  (except that we currently cannot reclaim it)

The only problem with this calculation is that it is also too
optimistic, since we've already counted all swapcached space as
free memory as well ...

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
