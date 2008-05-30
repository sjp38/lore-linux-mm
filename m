From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/2] hugetlb reservations v4/MAP_NORESERVE V3 cleanups
References: <20080528184246.4753a78b.akpm@linux-foundation.org>
Message-ID: <exportbomb.1212166524@pinky>
Date: Fri, 30 May 2008 17:57:21 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, abh@cray.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Following on from Andrew's feedback here are a couple of update patches
for hugetlb reservations v4 and MAP_NORESERVE V3.  These introduce a number
of new helpers and use those throughout.

This stack consists of two patches to allow them to be merged into the
appropriate stacks.

huge-page-private-reservation-review-cleanups -- adds the helpers and
  utilises them in the base reservations stack, and

huge-page-MAP_NORESERVE-review-cleanups -- uses the same helpers in the
  MAP_NORESERVE stack.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
