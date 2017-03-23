Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 707336B0343
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 03:49:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id v2so102182047lfi.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 00:49:59 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id n38si2842586lfi.228.2017.03.23.00.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 00:49:57 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id r36so15942498lfi.0
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 00:49:57 -0700 (PDT)
From: Kristaps Civkulis <kristaps.civkulis@gmail.com>
Subject: [PATCH 3/3] mm: fix a coding style issue
Date: Thu, 23 Mar 2017 09:49:02 +0200
Message-Id: <20170323074902.23768-1-kristaps.civkulis@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kristaps Civkulis <kristaps.civkulis@gmail.com>

Fix a coding style issue.

Signed-off-by: Kristaps Civkulis <kristaps.civkulis@gmail.com>
---
 mm/hugetlb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3d0aab9ee80d..4c72c1974c8c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1916,8 +1916,7 @@ static long __vma_reservation_common(struct hstate *h,
 			return 0;
 		else
 			return 1;
-	}
-	else
+	} else
 		return ret < 0 ? ret : 0;
 }
 
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
