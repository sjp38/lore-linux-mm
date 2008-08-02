Received: by wa-out-1112.google.com with SMTP id m28so908527wag.8
        for <linux-mm@kvack.org>; Sat, 02 Aug 2008 06:16:02 -0700 (PDT)
Date: Sat, 02 Aug 2008 21:16:02 +0800
From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: mm/hugetlb.c: removed duplicated #include
Message-Id: <20080802211031.D63E.WEIYI.HUANG@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Both commit 7cb93181629c613ee2b8f4ffe3446f8003074842 and
78a34ae29bf1c9df62a5bd0f0798b6c62a54d520 added #include <asm/io.h> 
in mm/hugetlb.c, but in 2 sightly different places.

This patch fixed it.

Signed-off-by: Huang Weiyi <hwy@cn.fujitsu.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 28a2980..d61b954 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -20,7 +20,6 @@
 #include <asm/io.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
-#include <asm/io.h>

 #include <linux/hugetlb.h>
 #include "internal.h"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
