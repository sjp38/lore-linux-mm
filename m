Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF586B0365
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:42:43 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id t87so35116318ioe.7
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:42:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h69si8141919ioi.188.2017.06.12.05.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:42:41 -0700 (PDT)
Date: Mon, 12 Jun 2017 05:42:24 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 15/20] fs: have call_fsync call filemap_report_wb_err
 if FS_WB_ERRSEQ is set
Message-ID: <20170612124224.GA18360@infradead.org>
References: <20170612122316.13244-1-jlayton@redhat.com>
 <20170612122316.13244-20-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170612122316.13244-20-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Mon, Jun 12, 2017 at 08:23:11AM -0400, Jeff Layton wrote:
> Allow filesystems to opt-in to a final check of wb_err if FS_WB_ERRSEQ
> is set. Technically, we could just plumb these calls into all of the
> fsync operations, but I think this means less code, changes and churn.

Please add it to every fs, that is a consistent with how we handle
everything else related to writeback.

Oh, and please kill this idiotic call_fsync helper while you're at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
