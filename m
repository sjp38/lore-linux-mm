Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4B96B00E6
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 17:33:52 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id z107so9648798qgd.18
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 14:33:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si27819167qgn.61.2014.11.12.14.33.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Nov 2014 14:33:51 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 3/3] hugetlb: hugetlb_register_all_nodes(): add __init marker
Date: Wed, 12 Nov 2014 17:33:13 -0500
Message-Id: <1415831593-9020-4-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, rientjes@google.com, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, davidlohr@hp.com

This function is only called during initialization.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a10fd57..9785546 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2083,7 +2083,7 @@ static void hugetlb_register_node(struct node *node)
  * devices of nodes that have memory.  All on-line nodes should have
  * registered their associated device by this time.
  */
-static void hugetlb_register_all_nodes(void)
+static void __init hugetlb_register_all_nodes(void)
 {
 	int nid;
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
