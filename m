Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA10581
	for <linux-mm@kvack.org>; Tue, 14 Apr 1998 17:03:42 -0400
Date: Tue, 14 Apr 1998 22:49:42 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: H.H.vanRiel@phys.uu.nl
Subject: Re: VM: question
In-Reply-To: <199804141724.MAA00666@kwr.hnv.com>
Message-ID: <Pine.LNX.3.91.980414224729.15681B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: kwr@hnv.com
Cc: linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Apr 1998 kwr@kwr.hnv.com wrote:

> memory", which sucks even on high-memory machines.  I tried to get
> reverse lookups implemented at one point, but things kept changing
> under me and I gave up...there's way too many places you have to
> change, IMHO...

Stephen and Ben are currently implementing this, it will
be in 2.3 :(

Up until that time, we'll have to provide some clever hacks,
like high and low water marks (leaving the disk idle for some
time, preventing thrashing) and clustering.

I'm not sure how to implement the high/low water mark however...
( Linus, do you have an idea on how to do this? )

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
