Date: Wed, 14 Jul 2004 23:06:36 +0900 (JST)
Message-Id: <20040714.230636.11986115.taka@valinux.co.jp>
Subject: [BUG] [PATCH] memory hotremoval for linux-2.6.7 [15/16]
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20040714.224138.95803956.taka@valinux.co.jp>
References: <20040714.224138.95803956.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--- linux-2.6.7/fs/direct-io.c.ORG	Fri Jun 18 13:52:47 2032
+++ linux-2.6.7/fs/direct-io.c	Fri Jun 18 13:53:49 2032
@@ -411,7 +411,7 @@ static int dio_bio_complete(struct dio *
 		for (page_no = 0; page_no < bio->bi_vcnt; page_no++) {
 			struct page *page = bvec[page_no].bv_page;
 
-			if (dio->rw == READ)
+			if (dio->rw == READ && !PageCompound(page))
 				set_page_dirty_lock(page);
 			page_cache_release(page);
 		}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
