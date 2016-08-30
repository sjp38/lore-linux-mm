Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6566B0038
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 19:01:54 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id le9so61597378pab.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 16:01:54 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si88060pfe.149.2016.08.30.16.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 16:01:53 -0700 (PDT)
Date: Tue, 30 Aug 2016 17:01:50 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 0/9] re-enable DAX PMD support
Message-ID: <20160830230150.GA12173@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Aug 23, 2016 at 04:04:10PM -0600, Ross Zwisler wrote:
> DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> locking.  This series allows DAX PMDs to participate in the DAX radix tree
> based locking scheme so that they can be re-enabled.
> 
> Changes since v1:
>  - PMD entry locking is now done based on the starting offset of the PMD
>    entry, rather than on the radix tree slot which was unreliable. (Jan)
>  - Fixed the one issue I could find with hole punch.  As far as I can tell
>    hole punch now works correctly for both PMD and PTE DAX entries, 4k zero
>    pages and huge zero pages.
>  - Fixed the way that ext2 returns the size of holes in ext2_get_block().
>    (Jan)
>  - Made the 'wait_table' global variable static in respnse to a sparse
>    warning.
>  - Fixed some more inconsitent usage between the names 'ret' and 'entry'
>    for radix tree entry variables.
> 
> Ross Zwisler (9):
>   ext4: allow DAX writeback for hole punch
>   ext2: tell DAX the size of allocation holes
>   ext4: tell DAX the size of allocation holes
>   dax: remove buffer_size_valid()
>   dax: make 'wait_table' global variable static
>   dax: consistent variable naming for DAX entries
>   dax: coordinate locking for offsets in PMD range
>   dax: re-enable DAX PMD support
>   dax: remove "depends on BROKEN" from FS_DAX_PMD
> 
>  fs/Kconfig          |   1 -
>  fs/dax.c            | 297 +++++++++++++++++++++++++++++-----------------------
>  fs/ext2/inode.c     |   3 +
>  fs/ext4/inode.c     |   7 +-
>  include/linux/dax.h |  29 ++++-
>  mm/filemap.c        |   6 +-
>  6 files changed, 201 insertions(+), 142 deletions(-)
> 
> -- 
> 2.9.0

Ping on this series?  Any objections or comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
