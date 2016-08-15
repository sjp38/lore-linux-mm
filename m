Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 920116B0261
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 15:09:54 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so116345612pac.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 12:09:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p4si19115744paz.202.2016.08.15.12.09.53
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 12:09:53 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 0/7] re-enable DAX PMD support
Date: Mon, 15 Aug 2016 13:09:11 -0600
Message-Id: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This series allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled.

This series restores DAX PMD functionality back to what it was before it
was disabled.  There is still a known issue between DAX PMDs and hole
punch, which I am currently working on and which I plan to address with a
separate series.

Ross Zwisler (7):
  ext2: tell DAX the size of allocation holes
  ext4: tell DAX the size of allocation holes
  dax: remove buffer_size_valid()
  dax: rename 'ret' to 'entry' in grab_mapping_entry
  dax: lock based on slot instead of [mapping, index]
  dax: re-enable DAX PMD support
  dax: remove "depends on BROKEN" from FS_DAX_PMD

 fs/Kconfig          |   1 -
 fs/dax.c            | 301 ++++++++++++++++++++++++++--------------------------
 fs/ext2/inode.c     |   6 ++
 fs/ext4/inode.c     |   3 +
 include/linux/dax.h |  30 +++++-
 mm/filemap.c        |   7 +-
 6 files changed, 191 insertions(+), 157 deletions(-)

-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
