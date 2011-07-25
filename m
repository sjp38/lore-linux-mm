Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6626B016A
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 19:19:35 -0400 (EDT)
From: Thomas Renninger <trenn@suse.de>
Subject: [PATCH] mm: Declare hugetlb_sysfs_add_hstate __meminit
Date: Tue, 26 Jul 2011 01:19:28 +0200
Message-Id: <1311635968-10107-1-git-send-email-trenn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@novell.com, Thomas Renninger <trenn@suse.de>, majordomo@kvack.org

Initially found by Mel, I just put this into a patch.

Signed-off-by: Thomas Renninger <trenn@suse.de>
Reviewed-by: Mel Gorman <mgorman@novell.com>
CC: majordomo@kvack.org
---
 mm/hugetlb.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bfcf153..2c59a0a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1543,9 +1543,10 @@ static struct attribute_group hstate_attr_group = {
 	.attrs = hstate_attrs,
 };
 
-static int hugetlb_sysfs_add_hstate(struct hstate *h, struct kobject *parent,
-				    struct kobject **hstate_kobjs,
-				    struct attribute_group *hstate_attr_group)
+static int
+__meminit hugetlb_sysfs_add_hstate(struct hstate *h, struct kobject *parent,
+				   struct kobject **hstate_kobjs,
+				   struct attribute_group *hstate_attr_group)
 {
 	int retval;
 	int hi = h - hstates;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
