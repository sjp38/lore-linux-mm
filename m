Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B587C6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:00:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c2so14888005pga.1
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 08:00:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w6si19271579pls.286.2017.04.24.08.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 08:00:26 -0700 (PDT)
Date: Mon, 24 Apr 2017 08:00:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC xfstests PATCH] xfstests: add a writeback error handling
 test
Message-ID: <20170424150019.GA3288@infradead.org>
References: <20170424134551.10301-1-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424134551.10301-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: fstests@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Mon, Apr 24, 2017 at 09:45:51AM -0400, Jeff Layton wrote:
> With the patch series above, ext4 now passes. xfs and btrfs end up in
> r/o mode after the test. xfs returns -EIO at that point though, and
> btrfs returns -EROFS. What behavior we actually want there, I'm not
> certain. We might be able to mitigate that by putting the journals on a
> separate device?

This looks like XFS shut down because of a permanent write error from
dm-error.  Which seems like the expected behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
