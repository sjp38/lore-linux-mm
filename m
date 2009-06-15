Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DB5B06B005C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 07:14:21 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/2] mm: Fix documentation of min_unmapped_ratio
Date: Mon, 15 Jun 2009 12:14:42 +0100
Message-Id: <1245064482-19245-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1245064482-19245-1-git-send-email-mel@csn.ul.ie>
References: <1245064482-19245-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Kosaki Motohiro pointed out that the documentation for
min_unmapped_ratio no longer matches the implementation. This patch
updates the documentation.

This patch can be merged with
vmscan-properly-account-for-the-number-of-page-cache-pages-zone_reclaim-can-re
claim.patch .

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/sysctl/vm.txt |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 0ea5adb..c4de635 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -315,10 +315,14 @@ min_unmapped_ratio:
 
 This is available only on NUMA kernels.
 
-A percentage of the total pages in each zone.  Zone reclaim will only
-occur if more than this percentage of pages are file backed and unmapped.
-This is to insure that a minimal amount of local pages is still available for
-file I/O even if the node is overallocated.
+This is a percentage of the total pages in each zone. Zone reclaim will
+only occur if more than this percentage of pages are in a state that
+zone_reclaim_mode allows to be reclaimed.
+
+If zone_reclaim_mode has the value 4 OR'd, then the percentage is compared
+against all file-backed unmapped pages including swapcache pages and tmpfs
+files. Otherwise, only unmapped pages backed by normal files but not tmpfs
+files and similar are considered.
 
 The default is 1 percent.
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
