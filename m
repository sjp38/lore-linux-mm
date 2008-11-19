Received: by fk-out-0910.google.com with SMTP id z22so3939049fkz.6
        for <linux-mm@kvack.org>; Tue, 18 Nov 2008 23:01:56 -0800 (PST)
Message-ID: <4923B9D3.8060203@gmail.com>
Date: Wed, 19 Nov 2008 08:01:39 +0100
From: Franck Bui-Huu <vagabon.xyz@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] do_mpage_readpage(): remove useless clear_buffer_mapped()
 call
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Franck Bui-Huu <fbuihuu@gmail.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Franck Bui-Huu <fbuihuu@gmail.com>
---
 Hello,

I just found this while reading mpage.c and it looks pretty obvious.

		Franck

 fs/mpage.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 552b80b..cf05ca7 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -241,7 +241,6 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 				first_hole = page_block;
 			page_block++;
 			block_in_file++;
-			clear_buffer_mapped(map_bh);
 			continue;
 		}
 
-- 
1.6.0.2.GIT


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
