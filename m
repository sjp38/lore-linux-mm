Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C88126B0390
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:24 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y33so40330302qta.7
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d23si2821198qta.288.2017.04.24.06.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:24 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 15/20] mm: remove AS_EIO and AS_ENOSPC flags
Date: Mon, 24 Apr 2017 09:22:54 -0400
Message-Id: <20170424132259.8680-16-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

They're no longer used.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/pagemap.h | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 32512ffc15fa..9593eac41499 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -20,13 +20,11 @@
  * Bits in mapping->flags.
  */
 enum mapping_flags {
-	AS_EIO		= 0,	/* IO error on async write */
-	AS_ENOSPC	= 1,	/* ENOSPC on async write */
-	AS_MM_ALL_LOCKS	= 2,	/* under mm_take_all_locks() */
-	AS_UNEVICTABLE	= 3,	/* e.g., ramdisk, SHM_LOCK */
-	AS_EXITING	= 4, 	/* final truncate in progress */
+	AS_MM_ALL_LOCKS	= 0,	/* under mm_take_all_locks() */
+	AS_UNEVICTABLE	= 1,	/* e.g., ramdisk, SHM_LOCK */
+	AS_EXITING	= 2, 	/* final truncate in progress */
 	/* writeback related tags are not used */
-	AS_NO_WRITEBACK_TAGS = 5,
+	AS_NO_WRITEBACK_TAGS = 3,
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
