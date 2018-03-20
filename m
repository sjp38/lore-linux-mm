Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 812E46B0006
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:02 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u1-v6so633887pls.5
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:02 -0700 (PDT)
Received: from out4438.biz.mail.alibaba.com (out4438.biz.mail.alibaba.com. [47.88.44.38])
        by mx.google.com with ESMTPS id t137si1718725pgb.288.2018.03.20.14.32.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:32:01 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 7/8] x86: mpx: pass atomic parameter to do_munmap()
Date: Wed, 21 Mar 2018 05:31:25 +0800
Message-Id: <1521581486-99134-8-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>, x86@kernel.org

Pass "true" to do_munmap() to not do unlock/relock to mmap_sem when
manipulating mpx map.

This is API change only.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: x86@kernel.org
---
 arch/x86/mm/mpx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index e500949..a180e94 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -780,7 +780,7 @@ static int unmap_entire_bt(struct mm_struct *mm,
 	 * avoid recursion, do_munmap() will check whether it comes
 	 * from one bounds table through VM_MPX flag.
 	 */
-	return do_munmap(mm, bt_addr, mpx_bt_size_bytes(mm), NULL);
+	return do_munmap(mm, bt_addr, mpx_bt_size_bytes(mm), NULL, true);
 }
 
 static int try_unmap_single_bt(struct mm_struct *mm,
-- 
1.8.3.1
