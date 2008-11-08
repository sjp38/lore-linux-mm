Message-Id: <20081108021512.686515000@suse.de>
Date: Sat, 08 Nov 2008 13:15:12 +1100
From: npiggin@suse.de
Subject: [patch 0/9] vmalloc fixes and improvements
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

Hi,

The following patches are a set of fixes and improvements for the vmap
layer.

Patches 1-3 fix "[Bug #11903] regression: vmalloc easily fail", and these
should go upstream for 2.6.28. They've been tested and shown to fix the
problem, and I've tested them here on my XFS stress test as well. The
off-by-one bug, I tested and verified in a userspace test harness (it
doesn't actually cause any corruption, but just suboptimal use of space).

Patches 4,5 are improvements to information exported to user. Not very risky,
but not urgent either.

Patches 6-9 improve locking, guard page scheme, put guard pages under
CONFIG_DEBUG_PAGEALLOC, and add a non-lazy-flush mode for
CONFIG_DEBUG_PAGEALLOC to catch use-after-free better. These are more
intrusive improvements. I'd like to see them merged, but they can happily
wait for next merge window.

Andrew, it's probably best if you take care of sending these upstream?

Thanks,
Nick
 
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
