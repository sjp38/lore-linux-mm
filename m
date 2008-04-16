From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/4] [RFC] Verification and debugging of memory initialisation
Date: Wed, 16 Apr 2008 14:50:58 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Boot initialisation has always been a bit of a mess with a number
of ugly points. While significant amounts of the initialisation
is architecture-independent, it trusts of the data received from the
architecture layer. This was a mistake in retrospect as it has resulted in
a number of difficult-to-diagnose bugs.

This patchset is an RFC to add some validation and tracing to memory
initialisation. It also introduces a few basic defencive measures and
depending on a boot parameter, will perform additional tests for errors
"that should never occur". I think this would have reduced debugging time
for some boot-related problems. The last part of the patchset is a similar
fix for the patch "[patch] mm: sparsemem memory_present() memory corruption"
that corrects a few more areas where similar errors were made.

I'm not looking to merge this as-is obviously but are there opinions on
whether this is a good idea in principal? Should it be done differently or
not at all?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
