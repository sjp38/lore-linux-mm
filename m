Received: by ti-out-0910.google.com with SMTP id j3so1694399tid.8
        for <linux-mm@kvack.org>; Fri, 25 Jul 2008 08:30:07 -0700 (PDT)
Date: Fri, 25 Jul 2008 23:30:05 +0800
From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: mm/sparse.c: Removed duplicated include
Message-Id: <20080725210703.912E.WEIYI.HUANG@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Removed duplicated include file "internal.h" in 
mm/sparse.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/mm/sparse.c b/mm/sparse.c
index 8ffc089..8e07810 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -12,7 +12,6 @@
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
-#include "internal.h"

 /*
  * Permanent SPARSEMEM data:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
