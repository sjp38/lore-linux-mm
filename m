Received: from rhino.thrillseeker.net (root@ci176196-a.grnvle1.sc.home.com [24.4.120.228])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA01751
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 21:52:08 -0500
Message-ID: <366C9447.2B4E9693@thrillseeker.net>
Date: Mon, 07 Dec 1998 21:51:51 -0500
From: Billy Harvey <Billy.Harvey@thrillseeker.net>
MIME-Version: 1.0
Subject: Re: [PATCH] swapin readahead and fixes
References: <Pine.LNX.3.96.981208032438.8407C-100000@mirkwood.dummy.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Mon, 7 Dec 1998, Billy Harvey wrote:
> 
> > Has anyone ever looked at the following concept?  In addition to a
> > swap-in read-ahead, have a swap-out write-ahead.  The idea is to use
> > all the avaialble swap space as a mirror of memory.
> 
> We do something a bit like this in 2.1.130+. Writing out all
> pages to swap will use far too much I/O bandwidth though, so
> we will never do that...
> 
Rik,

That's my point though about not taking I/O time away from other tasks. 
Only mirror pages to swap if there's nothing else blocked for I/O - put
any free time to work, and mirror pages if swap memory allows in
anticipation that it may be swapped out later.  I suppose a
least-recently-used approach on the pages would have the highest
payback.  I realize the CPU may be used a little more, but other than
rc5des it's idle a good bit of the time anyway - perhaps this could be
one step above an idle task.

Billy
-- 
Billy.Harvey@thrillseeker.net
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
