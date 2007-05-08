Subject: [KJ PATCH] Replacing memset(<addr>,0,PAGE_SIZE) with clear_page()
	in mm/memory.c
From: Shani Moideen <shani.moideen@wipro.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 08 May 2007 16:15:56 +0530
Message-Id: <1178621156.3598.10.camel@shani-win>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-janitors@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Hi,

Replacing memset(<addr>,0,PAGE_SIZE) with clear_page() in mm/memory.c.

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

thanks.


diff --git a/mm/memory.c b/mm/memory.c
index e7066e7..2780d07 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1505,7 +1505,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
                 * zeroes.
                 */
                if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
-                       memset(kaddr, 0, PAGE_SIZE);
+                       clear_page(kaddr);
                kunmap_atomic(kaddr, KM_USER0);
                flush_dcache_page(dst);
                return;


-- 
Shani 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
