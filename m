Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA21806
	for <linux-mm@kvack.org>; Tue, 24 Mar 1998 05:12:55 -0500
Date: Tue, 24 Mar 1998 10:48:39 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: 2.1.90 dies with many procs procs, partial fix
In-Reply-To: <Pine.LNX.3.95.980323140148.431A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.91.980324104322.14211D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Finn Arne Gangstad <finnag@guardian.no>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 1998, Linus Torvalds wrote:

> Of course, this is with some changes to the kswapd logic that I had
> anyway, so maybe they just behave really well, but I think the basic
> problem is that I have too much RAM to really see any bad behaviour. 
> 
> Anyway, I'm appending the diffs as I have them in my current pre-91 mm
> changes to let people comment on them..

I have some changes that do something like this (you've
already seen them :-), but with a little different kswapd
triggering.

The difference between a thrashing swapout madness, and
a harmless one seems to be the buffer_mem.min_percent,
ie. the page cache has a minimum RSS, so swapping can
continue without thrashing. This, combined with pagecache
aging, makes sure there's no real thrashing going on.

For example, yesterday evening my computer (24M) swapped
out some 14M in one swoop ... x11amp didn't skip a beat!

The hint that buffer_mem.min_percent is responsible for
remaining responsiveness was kindly given to me by xmem...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
