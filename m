Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id CA8989003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:04:43 -0400 (EDT)
Received: by ykfw73 with SMTP id w73so157058034ykf.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:04:43 -0700 (PDT)
Received: from m12-18.163.com (m12-18.163.com. [220.181.12.18])
        by mx.google.com with ESMTP id p9si12468675ywc.99.2015.08.25.07.04.41
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 07:04:43 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 2/2] Documentation: clarify in calculating zone protection
Date: Tue, 25 Aug 2015 22:01:31 +0800
Message-Id: <1440511291-3990-2-git-send-email-bywxiaobai@163.com>
In-Reply-To: <1440511291-3990-1-git-send-email-bywxiaobai@163.com>
References: <1440511291-3990-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Every zone's protection is calculated from managed_pages not
present_pages, to avoid misleading, correct it.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 Documentation/sysctl/vm.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9832ec5..1739b31 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -349,7 +349,7 @@ zone[i]'s protection[j] is calculated by following expression.
 
 (i < j):
   zone[i]->protection[j]
-  = (total sums of present_pages from zone[i+1] to zone[j] on the node)
+  = (total sums of managed_pages from zone[i+1] to zone[j] on the node)
     / lowmem_reserve_ratio[i];
 (i = j):
    (should not be protected. = 0;
@@ -360,7 +360,7 @@ The default values of lowmem_reserve_ratio[i] are
     256 (if zone[i] means DMA or DMA32 zone)
     32  (others).
 As above expression, they are reciprocal number of ratio.
-256 means 1/256. # of protection pages becomes about "0.39%" of total present
+256 means 1/256. # of protection pages becomes about "0.39%" of total managed
 pages of higher zones on the node.
 
 If you would like to protect more pages, smaller values are effective.
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
