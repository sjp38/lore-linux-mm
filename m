From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 11/26] VM: Allow get_page_unless_zero on compound pages
Date: Fri, 31 Aug 2007 18:41:18 -0700
Message-ID: <20070901014221.838742707@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0011-slab_defrag_get_page_unless.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

SLUB uses compound pages for larger slabs. We need to increment
the page count of these pages in order to make sure that they are not
freed under us for reclaim from within lumpy reclaim.

(The patch is also part of the large blocksize patchset)

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/mm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9fbb6ba..713d096 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -290,7 +290,7 @@ static inline int put_page_testzero(struct page *page)
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	VM_BUG_ON(PageCompound(page));
+	VM_BUG_ON(PageTail(page));
 	return atomic_inc_not_zero(&page->_count);
 }
 
-- 
1.5.2.4

-- 
