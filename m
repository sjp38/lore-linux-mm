Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA23916
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 05:09:33 -0400
Date: Mon, 6 Jul 1998 08:41:03 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: increasing page size
In-Reply-To: <Pine.LNX.3.95.980705212619.1514A-100000@localhost>
Message-ID: <Pine.LNX.3.96.980706083755.3995B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Gerard Roudier <groudier@club-internet.fr>
Cc: Peter-Paul Witta <e9525748@student.tuwien.ac.at>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 1998, Gerard Roudier wrote:
> On Sun, 5 Jul 1998, Rik van Riel wrote:
> 
> > Even if files are fragmented, readahead _will_ give a large
> > performance increase. This is because we can bring in the
> 
> This requires:
> 
> 1 - The program will really need the next page.
> 2 - The latency to get the next page is far lower than the program 
>     time execution before it will need of the next page.
> 3 - The page is still in memory when the program will 
>     need it.

With good algorithms, the kernel can make some quite proper
decisions on which readahead can be done and which readahead
is too expensive...

I believe Ingo's readahead code (not yet released) does something
like this. It analizes the programs' usage pattern and swaps in
until the page that has 50% probability of usage. If the program
soft-faults one of the preread pages, the kernel reads in the next
one(s) and this goes on until the kernel frees one of the preread
pages.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
