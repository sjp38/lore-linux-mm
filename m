Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 63FC26B007E
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:54:28 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/7] ceph: Push file_update_time() into ceph_page_mkwrite()
Date: Mon,  5 Mar 2012 15:54:14 +0100
Message-Id: <1330959258-23211-4-git-send-email-jack@suse.cz>
In-Reply-To: <1330959258-23211-1-git-send-email-jack@suse.cz>
References: <1330959258-23211-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Sage Weil <sage@newdream.net>, ceph-devel@vger.kernel.org

CC: Sage Weil <sage@newdream.net>
CC: ceph-devel@vger.kernel.org
Acked-by: Sage Weil <sage@newdream.net>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ceph/addr.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 173b1d2..12b139f 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1181,6 +1181,9 @@ static int ceph_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	loff_t size, len;
 	int ret;
 
+	/* Update time before taking page lock */
+	file_update_time(vma->vm_file);
+
 	size = i_size_read(inode);
 	if (off + PAGE_CACHE_SIZE <= size)
 		len = PAGE_CACHE_SIZE;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
