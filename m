Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9CA2803E9
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:29:34 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t3so44196919pgt.5
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:29:34 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t76si7342978pgc.539.2017.08.21.08.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 08:29:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 11/19] x86/mm: Make STACK_TOP_MAX dynamic
Date: Mon, 21 Aug 2017 18:29:08 +0300
Message-Id: <20170821152916.40124-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For boot-time switching between paging modes, we need to be able to
change STACK_TOP_MAX at runtime.

The change is trivial and it doesn't affect kernel image size.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/processor.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index c1352771b2f6..981cb956d8bf 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -871,7 +871,7 @@ static inline void spin_lock_prefetch(const void *x)
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 
 #define STACK_TOP		TASK_SIZE_LOW
-#define STACK_TOP_MAX		TASK_SIZE_MAX
+#define STACK_TOP_MAX		(pgtable_l5_enabled ? TASK_SIZE_MAX : DEFAULT_MAP_WINDOW)
 
 #define INIT_THREAD  {						\
 	.sp0			= TOP_OF_INIT_STACK,		\
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
