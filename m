Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id DA9616B0002
	for <linux-mm@kvack.org>; Sun, 12 May 2013 22:19:58 -0400 (EDT)
From: Libin <huawei.libin@huawei.com>
Subject: [PATCH] char: Use vma_pages() to replace (vm_end - vm_start) >> PAGE_SHIFT
Date: Mon, 13 May 2013 10:17:39 +0800
Message-ID: <1368411459-52524-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, guohanjun@huawei.com, wangyijing@huawei.com

(*->vm_end - *->vm_start) >> PAGE_SHIFT operation is implemented
as a inline funcion vma_pages() in linux/mm.h, so using it.

Signed-off-by: Libin <huawei.libin@huawei.com>
---
 drivers/char/mspec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/char/mspec.c b/drivers/char/mspec.c
index e1f60f9..f1d7fa4 100644
--- a/drivers/char/mspec.c
+++ b/drivers/char/mspec.c
@@ -267,7 +267,7 @@ mspec_mmap(struct file *file, struct vm_area_struct *vma,
 	if ((vma->vm_flags & VM_WRITE) == 0)
 		return -EPERM;
 
-	pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+	pages = vma_pages(vma);
 	vdata_size = sizeof(struct vma_data) + pages * sizeof(long);
 	if (vdata_size <= PAGE_SIZE)
 		vdata = kzalloc(vdata_size, GFP_KERNEL);
-- 
1.8.2.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
