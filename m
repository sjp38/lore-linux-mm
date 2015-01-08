Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id E8F3C6B006C
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 12:46:27 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id z12so3944587wgg.13
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 09:46:27 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gi3si14520687wib.83.2015.01.08.09.46.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 09:46:26 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: backing_dev_info cleanups & lifetime rule fixes
Date: Thu,  8 Jan 2015 18:45:21 +0100
Message-Id: <1420739133-27514-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

The first 8 patches are unchanged from the series posted a week ago and
cleans up how we use the backing_dev_info structure in preparation for
fixing the life time rules for it.  The most important change is to
split the unrelated nommu mmap flags from it, but it also remove a
backing_dev_info pointer from the address_space (and thus the inode)
and cleans up various other minor bits.

The remaining patches sort out the issues around bdi_unlink and now
let the bdi life until it's embedding structure is freed, which must
be equal or longer than the superblock using the bdi for writeback,
and thus gets rid of the whole mess around reassining inodes to new
bdis.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
