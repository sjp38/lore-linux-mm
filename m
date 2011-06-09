Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B983C6B00E7
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 14:20:45 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1584897Ab1FISUf (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 9 Jun 2011 20:20:35 +0200
Date: Thu, 9 Jun 2011 20:20:35 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH] mm: Simplify code by SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN() macro usage
Message-ID: <20110609182035.GC23592@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

git commit a539f3533b78e39a22723d6d3e1e11b6c14454d9 (mm: add SECTION_ALIGN_UP()
and SECTION_ALIGN_DOWN() macro) introduced SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN()
macro. Use those macros to increase code readability.

This patch applies to Linus' git tree, v3.0-rc2 tag.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 mm/page_cgroup.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 74ccff6..d818525 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -222,8 +222,8 @@ int __meminit online_page_cgroup(unsigned long start_pfn,
 	unsigned long start, end, pfn;
 	int fail = 0;
 
-	start = start_pfn & ~(PAGES_PER_SECTION - 1);
-	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
+	start = SECTION_ALIGN_DOWN(start_pfn);
+	end = SECTION_ALIGN_UP(start_pfn + nr_pages);
 
 	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
 		if (!pfn_present(pfn))
@@ -245,8 +245,8 @@ int __meminit offline_page_cgroup(unsigned long start_pfn,
 {
 	unsigned long start, end, pfn;
 
-	start = start_pfn & ~(PAGES_PER_SECTION - 1);
-	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
+	start = SECTION_ALIGN_DOWN(start_pfn);
+	end = SECTION_ALIGN_UP(start_pfn + nr_pages);
 
 	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
 		__free_page_cgroup(pfn);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
