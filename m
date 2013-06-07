Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 427CB6B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 08:08:51 -0400 (EDT)
Date: Fri, 7 Jun 2013 15:07:38 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -mm] mm, vmalloc: unbreak __vunmap()
Message-ID: <20130607120738.GA13851@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

There is an extra semi-colon so the function always returns.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91a1047..96b77a9 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1453,7 +1453,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 		return;
 
 	if (WARN(!PAGE_ALIGNED(addr), "Trying to vfree() bad address (%p)\n",
-			addr));
+			addr))
 		return;
 
 	area = remove_vm_area(addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
