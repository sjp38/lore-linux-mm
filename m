Received: from mail.inconnect.com (mail.inconnect.com [209.140.64.7])
	by kvack.org (8.8.7/8.8.7) with SMTP id AAA27129
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 00:05:45 -0500
Date: Sun, 10 Jan 1999 22:05:28 -0700 (MST)
From: Dax Kelson <dkelson@inconnect.com>
Subject: Re: [PATCH] MM fix & improvement
In-Reply-To: <Pine.LNX.3.95.990108235255.4363A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.04.9901102155440.1673-100000@brookie.inconnect.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, alan@lxorguk.ukuu.org.uk, sct@redhat.com, andrea@e-mind.com, alex@inconnect.com
List-ID: <linux-mm.kvack.org>


Not so fast.... :(

Here are the numbers (P2-400, 128MB SDRAM, one IDE drive), but the
interesting part is below:

./hogmem 200 3
Memory speed: 6.53 MB/sec

./hogmem 100 3 & ./hogmem 100 3 &
Memory speed: 1.74 MB/sec
Memory speed: 1.71 MB/sec

With pre6, Zlatko cleanup patch and MM fix and Linus's one line patch
(try_to_free_pages), while swapping with either the one hogmem, or both
running at the same time, the system is basically unusable for interactive
use.  Keyboard and mouse input is lagged several minutes, and switching
virtual desktops in X take forever.

With plain vanilla Pre6, the two hogmems would take a very long time to
complete, and the speed was < 1 MB/sec, however, the system was pretty
usuable.  I could switch virtual desktops in about 5-6 seconds, and mouse
input was slightly lagged, but typing in an xterm had no noticeable lag.

This kernel MM stuff is way way beyond my head, but I can test stuff. :)

Dax Kelson
Internet Connect, Inc.


On Fri, 8 Jan 1999, Linus Torvalds wrote:

> 
> 
> On 9 Jan 1999, Zlatko Calusic wrote:
> >
> > OK, here it goes. Patch is unbelievably small, and improvement is
> > BIG.
> 
> Looks good. Especially the fact that once again performance got a lot
> better by _removing_ some silly heuristics that didn't actually work.
> 
> Applied,
> 
> 		Linus
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/
> 





--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
