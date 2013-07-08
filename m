Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E27FF6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 05:52:14 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id lx15so3610842lab.35
        for <linux-mm@kvack.org>; Mon, 08 Jul 2013 02:52:12 -0700 (PDT)
Subject: [PATCH 3/5] hugetlbfs: remove cancel_dirty_page() from
 truncate_huge_page()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 08 Jul 2013 13:52:10 +0400
Message-ID: <20130708095210.13810.6106.stgit@zurg>
In-Reply-To: <20130708095202.13810.11659.stgit@zurg>
References: <20130708095202.13810.11659.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>

There is no backend and writeback, dirty pages accounting is disabled.
ClearPageDirty() more suits for this place.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
---
 fs/hugetlbfs/inode.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a3f868a..548badf 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -323,7 +323,7 @@ static int hugetlbfs_write_end(struct file *file, struct address_space *mapping,
 
 static void truncate_huge_page(struct page *page)
 {
-	cancel_dirty_page(page, /* No IO accounting for huge pages? */0);
+	ClearPageDirty(page);
 	ClearPageUptodate(page);
 	delete_from_page_cache(page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
