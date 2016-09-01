Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13C8882F66
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:56:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o15so26246027pfi.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:56:59 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id pv7si4102251pac.166.2016.08.31.23.56.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:56:58 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 15/16] Documentation: remove the constraint on the distances of node pairs
Date: Thu, 1 Sep 2016 14:55:06 +0800
Message-ID: <1472712907-12700-16-git-send-email-thunder.leizhen@huawei.com>
In-Reply-To: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
References: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank
 Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong
 Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

At present, the distances must equal in both direction for each node
pairs. For example: the distance of node B->A must the same to A->B.
But we really don't have to do this.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 Documentation/devicetree/bindings/numa.txt | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/numa.txt b/Documentation/devicetree/bindings/numa.txt
index 21b3505..f7234cd 100644
--- a/Documentation/devicetree/bindings/numa.txt
+++ b/Documentation/devicetree/bindings/numa.txt
@@ -48,15 +48,19 @@ distance (memory latency) between all numa nodes.

   Note:
 	1. Each entry represents distance from first node to second node.
-	The distances are equal in either direction.
 	2. The distance from a node to self (local distance) is represented
 	with value 10 and all internode distance should be represented with
 	a value greater than 10.
-	3. distance-matrix should have entries in lexicographical ascending
+	3. For non-local node pairs:
+	  1) If both direction specified, keep no change.
+	  2) If only one direction specified, assign it to the other direction.
+	  3) If none of the two direction specified, both are assigned to
+	     REMOTE_DISTANCE.
+	4. distance-matrix should have entries in lexicographical ascending
 	order of nodes.
-	4. There must be only one device node distance-map which must
+	5. There must be only one device node distance-map which must
 	reside in the root node.
-	5. If the distance-map node is not present, a default
+	6. If the distance-map node is not present, a default
 	distance-matrix is used.

 Example:
--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
