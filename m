From: Liu Xiang <liu.xiang6@zte.com.cn>
Subject: [PATCH] mm/filemap.c: Simplify the calculation of ra->prev_pos
Date: Fri, 25 Jan 2019 21:34:48 +0800
Message-ID: <1548423288-4225-1-git-send-email-liu.xiang6@zte.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, liuxiang_1999@126.com, Liu Xiang <liu.xiang6@zte.com.cn>
List-Id: linux-mm.kvack.org

The calculation of ra->prev_pos can be simplified.

Signed-off-by: Liu Xiang <liu.xiang6@zte.com.cn>
---
 mm/filemap.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323..7f30844 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2279,9 +2279,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
 would_block:
 	error = -EAGAIN;
 out:
-	ra->prev_pos = prev_index;
-	ra->prev_pos <<= PAGE_SHIFT;
-	ra->prev_pos |= prev_offset;
+	ra->prev_pos = (prev_index << PAGE_SHIFT) | prev_offset;
 
 	*ppos = ((loff_t)index << PAGE_SHIFT) + offset;
 	file_accessed(filp);
-- 
1.9.1
