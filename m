Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8D3900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 14:12:07 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so248878103pdb.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 11:12:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ql2si3939518pbc.204.2015.04.21.11.12.06
        for <linux-mm@kvack.org>;
        Tue, 21 Apr 2015 11:12:06 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] mm, hwpoison: Add comment describing when to add new cases
Date: Tue, 21 Apr 2015 11:11:30 -0700
Message-Id: <1429639890-14116-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Here's another comment fix for hwpoison.

It describes the "guiding principle" on when to add new
memory error recovery code.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 25c2054..d553993 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -20,6 +20,13 @@
  * this code has to be extremely careful. Generally it tries to use 
  * normal locking rules, as in get the standard locks, even if that means 
  * the error handling takes potentially a long time.
+ *
+ * It can be very tempting to add handling for obscure cases here.
+ * In general any code for handling new cases should only be added if:
+ * - You know how to test it.
+ * - You have a test that can be added to mce-test
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
