Received: from ferret.lmh.ox.ac.uk (qmailr@ferret.lmh.ox.ac.uk [163.1.138.204])
	by kvack.org (8.8.7/8.8.7) with SMTP id OAA13314
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 14:25:49 -0500
Date: Fri, 4 Dec 1998 19:25:31 +0000 (GMT)
From: Chris Evans <chris@ferret.lmh.ox.ac.uk>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <Pine.LNX.3.96.981203184928.2886A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.981204192244.28834B-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>



On Thu, 3 Dec 1998, Rik van Riel wrote:

> Hi,
> 
> here is a patch (against 2.1.130, but vs. 2.1.131 should
> be trivial) that improves the swapping performance both
> during swapout and swapin and contains a few minor fixes.

Hi Rik,

I'm very interested in performance for sequential swapping. This occurs in
for example scientific applications which much sweep through vast arrays
much larger than physical RAM.

Have you benchmarked booting with low physical RAM, lots of swap and
writing a simple program that allocates 100's of Mb of memory and then
sequentially accesses every page in a big loop?

This is one area in which FreeBSD stomps on us. Theoretically it should be
possible to get swap with readahead pulling pages into RAM at disk speed.

Cheers
Chris

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
