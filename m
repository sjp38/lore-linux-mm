Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8CD6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 07:05:09 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 85so320752104ioq.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 04:05:09 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id x7si31087976itb.58.2016.05.31.04.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 04:05:08 -0700 (PDT)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 31 May 2016 05:05:06 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm/debug: Add VM_WARN which maps to WARN()
Date: Tue, 31 May 2016 16:34:47 +0530
Message-Id: <1464692688-6612-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This enables us to do VM_WARN(condition, "warn message");
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/mmdebug.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index de7be78c6f0e..451a811f48f2 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -39,6 +39,7 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ON(cond) WARN_ON(cond)
 #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
+#define VM_WARN(cond, format...) WARN(cond, format)
 #else
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
@@ -47,6 +48,7 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
+#define VM_WARN(cond, format...) BUILD_BUG_ON_INVALID(cond)
 #endif
 
 #ifdef CONFIG_DEBUG_VIRTUAL
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
