Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA18700
	for <linux-mm@kvack.org>; Thu, 12 Mar 1998 14:33:15 -0500
Date: Thu, 12 Mar 1998 20:30:16 +0100
Message-Id: <199803121930.UAA12322@boole.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <Pine.LNX.3.91.980312000536.14217A-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Thu, 12 Mar 1998 00:11:38 +0100 (MET))
Subject: Re: 2.1.89 broken?
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: sct@dcs.ed.ac.uk, teg@pvv.ntnu.no, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> I've still got some Digital Unix-like balancing code
> lying around...
> Basically, you can set 3 values for the buffer/page
> cache, a minimum value, a maximum value and a steal
> value. When the buffer/page memory is above steal
> level and the system needs memory, it'll steal memory
> from the page cache first. A good default would be
> 25% of main memory. Of course, these values will be
> sysctl controllable (we still got 8 unused variables
> in swap_control ;-).

Does this mean that mm/filemap.c:shrink_mmap() would call
for it's self in mm/vmscan.c:kswapd() if the level is above
the limit?  ... without using mm/vmscan.c:(do_)try_to_free_page()
to become the buffer down without trashing the tasks?

This would need also a wrapper as it does for
do_try_to_free_page() to set/unset the kernel locks.

And this upper limit should be calculated dynamically because
there is a `small' difference between a 8Mb and a 512Mb
system ... the first systems should have a smaller amount
of buffer/cache to keep the system running :-)

           Werner
