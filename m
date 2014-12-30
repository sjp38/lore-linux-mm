Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC6A6B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 03:58:28 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id m14so696426wev.0
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 00:58:27 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ei2si48387574wib.99.2014.12.30.00.58.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Dec 2014 00:58:27 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: backing_dev_info cleanups
Date: Tue, 30 Dec 2014 09:57:31 +0100
Message-Id: <1419929859-24427-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org

This series cleans up how we use the backing_dev_info structure in 
preparation for fixing the life time rules for it.  The most important
change is to split the unrelated nommu mmap flags from it, but it
also remove a backing_dev_info pointer from the address_space 
(and thus the inode) and cleans up various other minor bits.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
