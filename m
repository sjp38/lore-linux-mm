Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21CA92806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:50:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 36so1551319qkz.10
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:50:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y78si399160qka.94.2017.05.09.08.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:50:29 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 17/27] mm: remove AS_EIO and AS_ENOSPC flags
Date: Tue,  9 May 2017 11:49:20 -0400
Message-Id: <20170509154930.29524-18-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

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
