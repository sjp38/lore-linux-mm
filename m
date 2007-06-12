Subject: [KJ PATCH] Replacing memcpy(dest,src,PAGE_SIZE) with
	copy_page(dest,src) in arch/i386/mm/init.c
From: Shani Moideen <shani.moideen@wipro.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jun 2007 08:46:14 +0530
Message-Id: <1181618174.2282.16.camel@shani-win>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-janitors@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Hi,
Replacing memcpy(dest,src,PAGE_SIZE) with copy_page(dest,src) in arch/i386/mm/init.c.

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----


diff --git a/arch/i386/mm/init.c b/arch/i386/mm/init.c
index ae43688..7dc3d46 100644
--- a/arch/i386/mm/init.c
+++ b/arch/i386/mm/init.c
@@ -397,7 +397,7 @@ char __nosavedata swsusp_pg_dir[PAGE_SIZE]
 
 static inline void save_pg_dir(void)
 {
-	memcpy(swsusp_pg_dir, swapper_pg_dir, PAGE_SIZE);
+	copy_page(swsusp_pg_dir, swapper_pg_dir);
 }
 #else
 static inline void save_pg_dir(void)

-- 
Regards,
Shani 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
