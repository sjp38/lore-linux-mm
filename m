From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/hugetlb: make node_hstates array static
Date: Sat, 17 Oct 2015 23:37:13 +0600
Message-ID: <1445103433-26603-1-git-send-email-kuleshovmail@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>
List-Id: linux-mm.kvack.org

There are no users of the node_hstates array outside of the
mm/hugetlb.c. So let's make it static.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9cc7734..3afd92f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2376,7 +2376,7 @@ struct node_hstate {
 	struct kobject		*hugepages_kobj;
 	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
 };
-struct node_hstate node_hstates[MAX_NUMNODES];
+static struct node_hstate node_hstates[MAX_NUMNODES];
 
 /*
  * A subset of global hstate attributes for node devices
-- 
2.6.0
