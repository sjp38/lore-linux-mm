Message-Id: <20081110133515.011510000@suse.de>
Date: Tue, 11 Nov 2008 00:35:15 +1100
From: npiggin@suse.de
Subject: [patch 0/7] vmalloc fixes and improvements #2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com
List-ID: <linux-mm.kvack.org>

Hopefully got attribution right.

Patches 1-3 fix "[Bug #11903] regression: vmalloc easily fail", and these
should go upstream for 2.6.28. They've been tested and shown to fix the
problem, and I've tested them here on my XFS stress test as well. The
off-by-one bug, I tested and verified in a userspace test harness (it
doesn't actually cause any corruption, but just suboptimal use of space).

Patches 4,5 are improvements to information exported to user. Not very risky,
but not urgent either.

Patches 6,7 improve locking and debugging modes a bit. I have not included
the changes to guard pages this time. They need a bit more explanation and
code review to justify. And probably some more philosophical discussions on
the mm list...

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
