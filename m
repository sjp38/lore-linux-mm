Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9B6466B0098
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 19:59:53 -0500 (EST)
Message-ID: <50A43E5E.9040905@xenotime.net>
Date: Wed, 14 Nov 2012 16:59:10 -0800
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: [PATCH 1/2] asm-generic: add __WARN() to bug.h
References: <20121114163042.64f0c0495663331b9c2d60d6@canb.auug.org.au>
In-Reply-To: <20121114163042.64f0c0495663331b9c2d60d6@canb.auug.org.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org

From: Randy Dunlap <rdunlap@infradead.org>

Add __WARN() macro for the case of CONFIG_BUG is not enabled.
This fixes a build error in mm/balloon_compaction.c.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org
Cc: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org
---
 include/asm-generic/bug.h |    4 ++++
 1 file changed, 4 insertions(+)

--- linux-next-20121114.orig/include/asm-generic/bug.h
+++ linux-next-20121114/include/asm-generic/bug.h
@@ -129,6 +129,10 @@ extern void warn_slowpath_null(const cha
 })
 #endif
 
+#ifndef __WARN
+#define __WARN()	do {} while (0)
+#endif
+
 #define WARN_TAINT(condition, taint, format...) WARN_ON(condition)
 
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
