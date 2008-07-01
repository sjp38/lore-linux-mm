From: Andy Whitcroft <apw@shadowen.org>
Subject: [RFC PATCH 0/4] Reclaim page capture v1
Date: Tue,  1 Jul 2008 18:58:38 +0100
Message-Id: <1214935122-20828-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

For sometime we have been looking at mechanisms for improving the availability
of larger allocations under load.  One of the options we have explored is
the capturing of pages freed under direct reclaim in order to increase the
chances of free pages coelescing before they are subject to reallocation
by racing allocators.

Following this email is a patch stack implementing page capture during
direct reclaim.  It consits of four patches.  The first two simply pull
out existing code into helpers for reuse.  The third makes buddy's use
of struct page explicit.  The fourth contains the meat of the changes,
and its leader contains a much fuller description of the feature.

I have done a fair amount of comparitive testing with and without
this patch set and in broad brush I am seeing improvements in hugepage
allocations (worst case size) success of the order of 5% which under
load for systems with larger hugepages represents a doubling of the number
of pages available.  Testing is still ongoing to confirm these results.

Against: 2.6.26-rc6 (with the explicit page flags patches)

Comments?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
