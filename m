Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC052806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:49:47 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n4so1492252qte.3
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:49:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c130si398488qka.169.2017.05.09.08.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:49:46 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 04/27] buffer: use mapping_set_error instead of setting the flag
Date: Tue,  9 May 2017 11:49:07 -0400
Message-Id: <20170509154930.29524-5-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/buffer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 9196f2a270da..70638941066d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -483,7 +483,7 @@ static void __remove_assoc_queue(struct buffer_head *bh)
 	list_del_init(&bh->b_assoc_buffers);
 	WARN_ON(!bh->b_assoc_map);
 	if (buffer_write_io_error(bh))
-		set_bit(AS_EIO, &bh->b_assoc_map->flags);
+		mapping_set_error(bh->b_assoc_map, -EIO);
 	bh->b_assoc_map = NULL;
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
