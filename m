Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA00872
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 04:14:16 -0500
Date: Thu, 26 Mar 1998 10:08:48 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: free_memory_available() bug in pre-91-1
In-Reply-To: <Pine.LNX.3.95.980325153614.17979T-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.91.980326100729.15920A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Mar 1998, Linus Torvalds wrote:

> On Wed, 25 Mar 1998, H.H.vanRiel wrote:
> > 
> > I've just found a bug in free_memory_available() as
> > implemented in pre-91-1...
> 
> Ugh, yes. How about pre-91-2, which I just put out? It has more of the
> code the way I _think_ it should be, and it should try a lot harder to not
> hog the CPU with kswapd. 

Actually, I was referring to the fact that free_memory_available()
returns 3 when there's not a single 128k area available...
In that case, it should return 2.

But I'll try pre-91-2.

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
