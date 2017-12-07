Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F17C6B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 05:11:40 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v69so3793324wrb.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 02:11:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q25sor1365658wmf.55.2017.12.07.02.11.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 02:11:39 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kcov: fix comparison callback signature
Date: Thu,  7 Dec 2017 11:11:34 +0100
Message-Id: <20171207101134.107168-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller@googlegroups.com, Alexander Potapenko <glider@google.com>, Vegard Nossum <vegard.nossum@oracle.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>

Fix a silly copy-paste bug.
We truncated u32 args to u16.

Fixes: ded97d2c2b2c ("kcov: support comparison operands collection")
Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: syzkaller@googlegroups.com
Cc: Alexander Potapenko <glider@google.com>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>
---
 kernel/kcov.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/kcov.c b/kernel/kcov.c
index 15f33faf4013..7594c033d98a 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -157,7 +157,7 @@ void notrace __sanitizer_cov_trace_cmp2(u16 arg1, u16 arg2)
 }
 EXPORT_SYMBOL(__sanitizer_cov_trace_cmp2);
 
-void notrace __sanitizer_cov_trace_cmp4(u16 arg1, u16 arg2)
+void notrace __sanitizer_cov_trace_cmp4(u32 arg1, u32 arg2)
 {
 	write_comp_data(KCOV_CMP_SIZE(2), arg1, arg2, _RET_IP_);
 }
@@ -183,7 +183,7 @@ void notrace __sanitizer_cov_trace_const_cmp2(u16 arg1, u16 arg2)
 }
 EXPORT_SYMBOL(__sanitizer_cov_trace_const_cmp2);
 
-void notrace __sanitizer_cov_trace_const_cmp4(u16 arg1, u16 arg2)
+void notrace __sanitizer_cov_trace_const_cmp4(u32 arg1, u32 arg2)
 {
 	write_comp_data(KCOV_CMP_SIZE(2) | KCOV_CMP_CONST, arg1, arg2,
 			_RET_IP_);
-- 
2.15.1.424.g9478a66081-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
