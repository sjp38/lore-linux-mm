Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA14208
	for <linux-mm@kvack.org>; Wed, 11 Mar 1998 20:02:16 -0500
Date: Thu, 12 Mar 1998 00:11:38 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: 2.1.89 broken?
In-Reply-To: <199803112237.WAA04217@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980312000536.14217A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Trond Eivind Glomsrod <teg@pvv.ntnu.no>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Mar 1998, Stephen C. Tweedie wrote:

> No, it's not necessarily doing the Right Thing.  The trouble is that
> there is no balancing between swapping and emptying the page cache.

I've still got some Digital Unix-like balancing code
lying around...
Basically, you can set 3 values for the buffer/page
cache, a minimum value, a maximum value and a steal
value. When the buffer/page memory is above steal
level and the system needs memory, it'll steal memory
from the page cache first. A good default would be
25% of main memory. Of course, these values will be
sysctl controllable (we still got 8 unused variables
in swap_control ;-).

> Now, once we've got a single pass which can scavenge BOTH page cache
> and swap pages, then we're really going to be cooking on gas. :)  For

I think we should just copy DU's scheme:
- when buffer/page cache is above steal level, we steal that memory
- otherwise, we steal in a round-robin fashion from both

> now, however, all we're doing is tweaking what is a very very delicate
> balance, and as we proved in the 1.2.4 and 1.2.5 swapping disasters,
> getting such a change done in a way which doesn't make at least
> somebody's performance very much worse is really quite hard to do in
> the current way of managing memory.  When I was doing the first round
> of work on kswap, it was this balance between cache and swap which was
> the biggest problem, not the aging of individual pages from either
> source.

That's why we have sysctl controllable swapping. And now
we're talking about it, the sysctl really needs updating
too...

You can expect these patches RSN (maybe even tomorrow).

grtz,

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
