Message-Id: <20080208233738.699960000@polaris-admin.engr.sgi.com>
References: <20080208233738.108449000@polaris-admin.engr.sgi.com>
Date: Fri, 08 Feb 2008 15:37:42 -0800
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 4/4] x86: minor cleanup of comments in processor.h
Content-Disposition: inline; filename=cleanup-processor.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Removal of trivial comments in processor.h

Based on linux-2.6.git + x86.git

Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/asm-x86/processor.h |    4 ----
 1 file changed, 4 deletions(-)

--- a/include/asm-x86/processor.h
+++ b/include/asm-x86/processor.h
@@ -302,10 +302,6 @@ union i387_union {
 };
 
 #ifdef CONFIG_X86_32
-/*
- * the following now lives in the per cpu area:
- * extern	int cpu_llc_id[NR_CPUS];
- */
 DECLARE_PER_CPU(u8, cpu_llc_id);
 #else
 DECLARE_PER_CPU(struct orig_ist, orig_ist);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
