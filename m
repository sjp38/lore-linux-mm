Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id A75566B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 21:10:32 -0400 (EDT)
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: [PATCH] mm: make validate_mm() static
Date: Tue, 15 May 2012 09:10:47 +0800
Message-Id: <1337044247-4006-1-git-send-email-yuanhan.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Yuanhan Liu <yuanhan.liu@linux.intel.com>

validate_mm() is just used in mmap.c only, thus make it static.

Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
---
 mm/mmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 848ef52..3e440f3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -335,7 +335,7 @@ static int browse_rb(struct rb_root *root)
 	return i;
 }
 
-void validate_mm(struct mm_struct *mm)
+static void validate_mm(struct mm_struct *mm)
 {
 	int bug = 0;
 	int i = 0;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
