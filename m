Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA24537
	for <linux-mm@kvack.org>; Tue, 24 Mar 1998 16:58:28 -0500
Date: Tue, 24 Mar 1998 21:17:55 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: minor patch for 2.1.90 fs/buffer.c
In-Reply-To: <35180539.13BA0CD8@star.net>
Message-ID: <Pine.LNX.3.91.980324211627.1182D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bill Hawes <whawes@star.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Mar 1998, Bill Hawes wrote:

> allocation would be required. (I recently observed a machine with 500M of RAM,
> heavily swapping, but with only 360 buffers, so this situation can occur.)

Indeed, you're completely right... I've noticed something like
this as well, although not as severe.

But maybe we should _limit_ the second-round allocation to
something less than half of the needed buffermem (say, 1/4th).

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
