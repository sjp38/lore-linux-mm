Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D06746B029E
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 20:01:40 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so118608089pab.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 17:01:40 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ra4si20253949pab.126.2015.10.02.17.01.39
        for <linux-mm@kvack.org>;
        Fri, 02 Oct 2015 17:01:40 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 0/2] Revert locking changes in DAX for v4.3
Date: Fri,  2 Oct 2015 18:01:32 -0600
Message-Id: <1443830494-8748-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org

This series reverts some recent changes to the locking scheme in DAX introduced
by these two commits:

commit 843172978bb9 ("dax: fix race between simultaneous faults")
commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")

Changes from v1:
 -  Squashed patches 1 and 2 from the first series into a single patch to avoid
    adding another spot in the git history where we could end up referencing an
    uninitialized pointer.

Ross Zwisler (2):
  Revert "mm: take i_mmap_lock in unmap_mapping_range() for DAX"
  Revert "dax: fix race between simultaneous faults"

 fs/dax.c    | 83 +++++++++++++++++++++++++------------------------------------
 mm/memory.c |  2 ++
 2 files changed, 36 insertions(+), 49 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
