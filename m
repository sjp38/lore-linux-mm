Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0048E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 18:24:04 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id r145so25222516qke.20
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 15:24:04 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c16sor29844652qtq.58.2018.12.27.15.24.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Dec 2018 15:24:03 -0800 (PST)
Date: Thu, 27 Dec 2018 15:23:54 -0800
Message-Id: <20181227232354.64562-1-ksspiers@google.com>
Mime-Version: 1.0
Subject: [PATCH] include/linux/gfp.h: fix typo
From: Kyle Spiers <ksspiers@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyle Spiers <ksspiers@google.com>

Fix misspelled "satisfied"

Signed-off-by: Kyle Spiers <ksspiers@google.com>
---
 include/linux/gfp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0705164f928c..5f5e25fd6149 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -81,7 +81,7 @@ struct vm_area_struct;
  *
  * %__GFP_HARDWALL enforces the cpuset memory allocation policy.
  *
- * %__GFP_THISNODE forces the allocation to be satisified from the requested
+ * %__GFP_THISNODE forces the allocation to be satisfied from the requested
  * node with no fallbacks or placement policy enforcements.
  *
  * %__GFP_ACCOUNT causes the allocation to be accounted to kmemcg.
-- 
2.20.1.415.g653613c723-goog
