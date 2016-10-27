Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B07926B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:41:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i85so9125324pfa.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:41:57 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p9si8276051pgd.213.2016.10.27.07.41.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 07:41:56 -0700 (PDT)
Date: Thu, 27 Oct 2016 08:41:55 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v8 00/16] re-enable DAX PMD support
Message-ID: <20161027144155.GB1238@linux.intel.com>
References: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed, Oct 19, 2016 at 01:34:19PM -0600, Ross Zwisler wrote:
> DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> locking.  This series allows DAX PMDs to participate in the DAX radix tree
> based locking scheme so that they can be re-enabled.
> 
> Changes since v7:
>  - Rebased on v4.9-rc1, dropping one ext4 patch that had already been merged.
>  - Added Reviewed-by tags from Jan Kara.
> 
> Here is a tree containing my changes:
> https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_v8
> 
> Ross Zwisler (16):
>   ext4: tell DAX the size of allocation holes
>   dax: remove buffer_size_valid()
>   ext2: remove support for DAX PMD faults
>   dax: make 'wait_table' global variable static
>   dax: remove the last BUG_ON() from fs/dax.c
>   dax: consistent variable naming for DAX entries
>   dax: coordinate locking for offsets in PMD range
>   dax: remove dax_pmd_fault()
>   dax: correct dax iomap code namespace
>   dax: add dax_iomap_sector() helper function
>   dax: dax_iomap_fault() needs to call iomap_end()
>   dax: move RADIX_DAX_* defines to dax.h
>   dax: move put_(un)locked_mapping_entry() in dax.c
>   dax: add struct iomap based DAX PMD support
>   xfs: use struct iomap based DAX PMD fault path
>   dax: remove "depends on BROKEN" from FS_DAX_PMD
> 
>  fs/Kconfig          |   1 -
>  fs/dax.c            | 826 +++++++++++++++++++++++++++++-----------------------
>  fs/ext2/file.c      |  35 +--
>  fs/ext4/inode.c     |   3 +
>  fs/xfs/xfs_aops.c   |  26 +-
>  fs/xfs/xfs_aops.h   |   3 -
>  fs/xfs/xfs_file.c   |  10 +-
>  include/linux/dax.h |  58 +++-
>  mm/filemap.c        |   5 +-
>  9 files changed, 537 insertions(+), 430 deletions(-)
> 
> -- 
> 2.7.4

Ping on this series.  Dave, is the plan still for you to pull this in via the
XFS development tree?  Do you need anything else on my side for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
