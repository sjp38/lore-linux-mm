Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1FFF4900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 19:35:11 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so255216194pab.3
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 16:35:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id jq4si4948008pbc.110.2015.04.21.16.35.10
        for <linux-mm@kvack.org>;
        Tue, 21 Apr 2015 16:35:10 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] mm, hwpoison: Add comment describing when to add new cases
Date: Tue, 21 Apr 2015 16:35:05 -0700
Message-Id: <1429659305-14734-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Here's another comment fix for hwpoison.

It describes the "guiding principle" on when to add new
memory error recovery code.

v2: Add URL
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 25c2054..97e44d3 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -20,6 +20,14 @@
  * this code has to be extremely careful. Generally it tries to use 
  * normal locking rules, as in get the standard locks, even if that means 
  * the error handling takes potentially a long time.
+ *
+ * It can be very tempting to add handling for obscure cases here.
+ * In general any code for handling new cases should only be added iff:
+ * - You know how to test it.
+ * - You have a test that can be added to mce-test
+ *   https://git.kernel.org/cgit/utils/cpu/mce/mce-test.git/
+ * - The case actually shows up as a frequent (top 10) page state in
+ *   tools/vm/page-types when running a real workload.
  * 
  * There are several operations here with exponential complexity because
  * of unsuitable VM data structures. For example the operation to map back 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
