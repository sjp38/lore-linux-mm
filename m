Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA11306
	for <linux-mm@kvack.org>; Tue, 3 Mar 1998 10:02:26 -0500
Date: Tue, 3 Mar 1998 14:10:20 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [PATCH] kswapd fix & logic improvement 
In-Reply-To: <199803031135.MAA19461@max.fys.ruu.nl>
Message-ID: <Pine.LNX.3.91.980303140552.21962A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: jahakala@cc.jyu.fi
Cc: linux-mm <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 1998, Jani Hakala wrote:

> I patched pre5 with your diff.  Now I get 'kswapd: failed, got 73 of 
> 128' messages all the time.

Maybe you should play around a little with /proc/sys/vm/swapctl
and /proc/sys/vm/freepages...
A 1:2:4 ratio for freepages usualy works wonders.
And a echo "10 3 1 3 0 0 0 0 1024" > swapctl gives some
improvement too. As a matter of fact, I'm currently (read:
now) removing some of the 1.1.xx artifacts from mm/vmscan.c...

Things will straighten up RSN, but until that time, you can:
- tune /proc/sys/vm/*
- tune mm/vmscan.c (just make it more agressive)

The main reason that you didn't get that message with the
old kernel is that it doesn't show you the error, but
you're right, I should limit the printout of the error
(to once every 5 seconds?).

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
