Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA05317
	for <linux-mm@kvack.org>; Thu, 8 Jan 1998 18:12:40 -0500
Date: Fri, 9 Jan 1998 00:05:24 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: [patch *] mmap-age 2.1.78 released.
Message-ID: <Pine.LNX.3.91.980108235813.3139A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.rutgers.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I am proud to announce to you the new version of mmap-age :-)

This patch is an enhancement for the VM subsystem, it:
- combats fragmentation (albeit in a primitive, but effective way)
- makes the slab-system somewhat friendlier to the VM system
- ages mmap'ed pages, for higher performance
- makes kswapd a bit more intelligent, so there's less chance
  of running out of memory / large fragments.

As usual, kudo's to Zlatko Calusic for the anti-frag stuff...

You can get it from my homepage. If you throw this message
away and can't remember the address later, my homepage can
be reached via LinuxHQ -> 21unoff.html.

It's all 'tried and tested' code, so it should be safe.
And with the improved logic and Linus' old allocation code,
it works better than ever...

As usual, reports are welcomed,

Rik.

ps. I'd really like to get this into 2.2 if we can't find a
better solution against fragmentation. And the extra performance
also comes in handy :-)
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
