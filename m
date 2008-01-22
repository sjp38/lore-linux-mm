Message-Id: <20080122211528.797776000@sgi.com>
References: <20080122211528.602673000@sgi.com>
Date: Tue, 22 Jan 2008 13:15:29 -0800
From: travis@sgi.com
Subject: [PATCH 1/1] fix possible undefined PER_CPU_ATTRIBUTES
Content-Disposition: inline; filename=fix-PER_CPU_ATTRIBUTES-define
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Not sure how this leaked out and I haven't caught it yet in my
cross-build testing but to be on the safe side, PER_CPU_ATTRIBUTES
should be defined.

Applies to 2.6.24-rc8-mm1 + percpu changes

Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/percpu.h |    4 ++++
 1 file changed, 4 insertions(+)

--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -9,6 +9,10 @@
 
 #include <asm/percpu.h>
 
+#ifndef PER_CPU_ATTRIBUTES
+#define PER_CPU_ATTRIBUTES
+#endif
+
 #ifdef CONFIG_SMP
 #define DEFINE_PER_CPU(type, name)					\
 	__attribute__((__section__(".data.percpu")))			\

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
