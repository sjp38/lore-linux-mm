Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 3D4DE6B020B
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 01:36:05 -0500 (EST)
Received: by iahk25 with SMTP id k25so13013055iah.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 22:36:04 -0800 (PST)
Message-ID: <4EE6F24B.7050204@gmail.com>
Date: Tue, 13 Dec 2011 14:35:55 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm/hugetlb.c: cleanup to use long vars instead of int in
 region_count
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

args f & t and fields from & to of struct file_region are defined
as long. Use long instead of int to type the temp vars.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/hugetlb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dae27ba..e666287 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -195,8 +195,8 @@ static long region_count(struct list_head *head, long f, long t)
 
 	/* Locate each segment we overlap with, and count that overlap. */
 	list_for_each_entry(rg, head, link) {
-		int seg_from;
-		int seg_to;
+		long seg_from;
+		long seg_to;
 
 		if (rg->to <= f)
 			continue;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
