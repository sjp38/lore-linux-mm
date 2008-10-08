From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/1] gigantic compound pages part 2
Date: Wed,  8 Oct 2008 10:33:50 +0100
Message-Id: <1223458431-12640-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Full stress testing of 2.6.27-rc7 with the patch below threw up some
more places where we assume the mem_map is contigious:

	handle initialising compound pages at orders greater than MAX_ORDER

Following this email is an additional patch to fix up those places.
With this patch the libhugetlbfs functional tests pass, as do our stress
test loads.

Thanks to Jon Tollefson for his help testing these patches.

Please consider this patch for merge for 2.6.27.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
