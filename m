Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8361E6B02FA
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:08:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y129so172043610pgy.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:08:32 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id t9si4102201plm.68.2017.07.27.05.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:08:31 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id y25so10625776pfk.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:08:31 -0700 (PDT)
From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 5/5] mm: hugetlb: constify attribute_group structures.
Date: Thu, 27 Jul 2017 17:37:40 +0530
Message-Id: <1501157260-3922-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, khandual@linux.vnet.ibm.com, aarcange@redhat.com, gerald.schaefer@de.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/sysfs.h> work with
const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 mm/hugetlb.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc48ee7..2ecd09d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2569,13 +2569,13 @@ static ssize_t surplus_hugepages_show(struct kobject *kobj,
 	NULL,
 };
 
-static struct attribute_group hstate_attr_group = {
+static const struct attribute_group hstate_attr_group = {
 	.attrs = hstate_attrs,
 };
 
 static int hugetlb_sysfs_add_hstate(struct hstate *h, struct kobject *parent,
 				    struct kobject **hstate_kobjs,
-				    struct attribute_group *hstate_attr_group)
+				    const struct attribute_group *hstate_attr_group)
 {
 	int retval;
 	int hi = hstate_index(h);
@@ -2633,7 +2633,7 @@ struct node_hstate {
 	NULL,
 };
 
-static struct attribute_group per_node_hstate_attr_group = {
+static const struct attribute_group per_node_hstate_attr_group = {
 	.attrs = per_node_hstate_attrs,
 };
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
