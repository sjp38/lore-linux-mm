Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67F1C2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 08:48:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p74so4089740pfd.11
        for <linux-mm@kvack.org>; Wed, 10 May 2017 05:48:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v74si2893935pfj.391.2017.05.10.05.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 05:48:40 -0700 (PDT)
Date: Wed, 10 May 2017 05:48:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 06/27] fs: check for writeback errors after syncing
 out buffers in generic_file_fsync
Message-ID: <20170510124836.GA1590@bombadil.infradead.org>
References: <20170509154930.29524-1-jlayton@redhat.com>
 <20170509154930.29524-7-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509154930.29524-7-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Tue, May 09, 2017 at 11:49:09AM -0400, Jeff Layton wrote:
> ext2 currently does a test+clear of the AS_EIO flag, which is
> is problematic for some coming changes.
> 
> What we really need to do instead is call filemap_check_errors
> in __generic_file_fsync after syncing out the buffers. That
> will be sufficient for this case, and help other callers detect
> these errors properly as well.
> 
> With that, we don't need to twiddle it in ext2.
> 
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Jan Kara <jack@suse.cz>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
