From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/2] Lumpy Reclaim V6 cleanups
Message-ID: <exportbomb.1177520981@pinky>
Date: Wed, 25 Apr 2007 18:09:41 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Following this email are two cleanup patches against lumpy V6
(as contained in v2.6.21-rc7-mm1).  These address the review feedback
from Andrew Morton, thanks for reviewing.

introduce-HIGH_ORDER-delineating-easily-reclaimable-orders-fix:
  changes the name of the constant to PAGE_ALLOC_COSTLY_ORDER and
  updates the commentary to better describe it.

lumpy-increase-pressure-at-the-end-of-the-inactive-list-cleanups:
  a large number of cleanups including fully expressing the
  isolations modes symbolically.

Andrew please apply.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
