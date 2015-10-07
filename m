Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1286B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 18:58:54 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so33934098pab.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 15:58:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yi1si61140198pbb.246.2015.10.07.15.58.53
        for <linux-mm@kvack.org>;
        Wed, 07 Oct 2015 15:58:53 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5] Fix DAX deadlocks for v4.3
Date: Wed,  7 Oct 2015 16:58:48 -0600
Message-Id: <1444258729-21974-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <matthew.r.wilcox@intel.com>

This was previously "Revert locking changes in DAX for v4.3".

Undo some recent changes to the locking scheme in DAX introduced by these two
commits:

commit 843172978bb9 ("dax: fix race between simultaneous faults")
commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")

Changes from v4:
 - Collapsed two revert commits into a single fix commit.  No code changes were
   made.

Ross Zwisler (1):
  mm, dax: fix DAX deadlocks

 fs/dax.c    | 70 +++++++++++++++++++++++++------------------------------------
 mm/memory.c |  2 ++
 2 files changed, 31 insertions(+), 41 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
