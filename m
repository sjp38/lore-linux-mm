Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 90A826B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 04:43:42 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so26828411wib.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 01:43:41 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id h4si3499117wij.12.2015.01.14.01.43.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 01:43:41 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: backing_dev_info cleanups & lifetime rule fixes V2
Date: Wed, 14 Jan 2015 10:42:29 +0100
Message-Id: <1421228561-16857-1-git-send-email-hch@lst.de>
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

Changes since V1:
 - various minor documentation updates based on Feedback from Tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
