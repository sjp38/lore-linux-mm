Received: from sun4.apsoft.com (sun4.apsoft.com [209.1.28.81])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA10747
	for <linux-mm@kvack.org>; Tue, 14 Apr 1998 17:37:50 -0400
From: Perry Harrington <pedward@sun4.apsoft.com>
Message-Id: <199804142127.OAA09136@sun4.apsoft.com>
Subject: Re: new kmod.c - debuggers and testers needed
Date: Tue, 14 Apr 1998 14:27:53 -0700 (PDT)
In-Reply-To: <Pine.LNX.3.91.980414200024.1070J-100000@mirkwood.dummy.home> from "Rik van Riel" at Apr 14, 98 08:02:09 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Tue, 7 Apr 1998, Perry Harrington wrote:
> 
> >                                                           Threads
> > are useful in their appropriate context, and kswapd, and kmod would benefit
> > from them.
> 
> Hmm, maybe it would be useful for kswapd and bdflush to fork()
> off threads to do the actual disk I/O, so the main thread won't
> be blocked and paused... This could remove some bottlenecks.

I was thinking that kswapd could use some of it's spare time to do an LRU
paging scan, consolidate free space, and possibly do remapping of process
memory spaces to make them more efficient (map pages to contiguous chunks
of memory and swap).

> 
> Rik.

--Perry

-- 
Perry Harrington       Linux rules all OSes.    APSoft      ()
email: perry@apsoft.com 			Think Blue. /\
