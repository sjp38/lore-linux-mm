Return-Path: <linux-kernel-owner@vger.kernel.org>
Subject: [PATCH] mm: Remove useless check in pagecache_get_page()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Fri, 07 Dec 2018 18:46:24 +0300
Message-ID: <154419752044.18559.2452963074922917720.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, gorcunov@virtuozzo.com, ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

page always is not NULL, so we may remove this useless check.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/filemap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b1165a311a1f..5da9ce090898 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1601,7 +1601,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		VM_BUG_ON_PAGE(page->index != offset, page);
 	}
 
-	if (page && (fgp_flags & FGP_ACCESSED))
+	if (fgp_flags & FGP_ACCESSED)
 		mark_page_accessed(page);
 
 no_page:
