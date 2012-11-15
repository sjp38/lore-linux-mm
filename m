Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id B461E6B009A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 20:00:06 -0500 (EST)
Message-ID: <50A43E64.3040709@infradead.org>
Date: Wed, 14 Nov 2012 16:59:16 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm: balloon_compaction.c needs asm-generic/bug.h
References: <20121114163042.64f0c0495663331b9c2d60d6@canb.auug.org.au>
In-Reply-To: <20121114163042.64f0c0495663331b9c2d60d6@canb.auug.org.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix build when CONFIG_BUG is not enabled by adding header file
<asm-generic/bug.h>:

mm/balloon_compaction.c: In function 'balloon_page_putback':
mm/balloon_compaction.c:243:3: error: implicit declaration of function '__WARN'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Rafael Aquini <aquini@redhat.com>
---
 mm/balloon_compaction.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20121114.orig/mm/balloon_compaction.c
+++ linux-next-20121114/mm/balloon_compaction.c
@@ -9,6 +9,7 @@
 #include <linux/slab.h>
 #include <linux/export.h>
 #include <linux/balloon_compaction.h>
+#include <asm-generic/bug.h>
 
 /*
  * balloon_devinfo_alloc - allocates a balloon device information descriptor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
