Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 004FF6B0081
	for <linux-mm@kvack.org>; Sat, 12 May 2012 07:53:14 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6116916pbb.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 04:53:14 -0700 (PDT)
Date: Sat, 12 May 2012 04:52:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/10] shmem/tmpfs: misc and fallocate
Message-ID: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Here's a bunch of shmem/tmpfs updates: mostly completed in January,
then put aside while I attended to other stuff.  But the more recent
1/10 has some urgency, so I'm expediting the descriptions, and shipping
them off to you now for v3.5.

They're diffed against 3.4.0-rc5-next-20120504, but
apply and build and work on most v3.4-rc and v3.4-rc-next.

The fallocate ones were prompted by posts from Cong Wang in November:
I've attributed four of those with Based-on-patch-by, but could not
put From or Signed-off-by, since the originals were somewhat flawed,
and I needed to start again and reorder it all.

Whether 10/10 should go any further than exposure in -next
is in doubt: we shall have to see if it's useful to anyone.

 1/10 shmem: replace page if mapping excludes its zone
 2/10 tmpfs: enable NOSEC optimization
 3/10 tmpfs: optimize clearing when writing
 4/10 tmpfs: support fallocate FALLOC_FL_PUNCH_HOLE
 5/10 mm/fs: route MADV_REMOVE to FALLOC_FL_PUNCH_HOLE
 6/10 mm/fs: remove truncate_range
 7/10 tmpfs: support fallocate preallocation
 8/10 tmpfs: undo fallocation on failure
 9/10 tmpfs: quit when fallocate fills memory
10/10 tmpfs: support SEEK_DATA and SEEK_HOLE

 Documentation/filesystems/Locking |    2 
 Documentation/filesystems/vfs.txt |   13 
 drivers/staging/android/ashmem.c  |    8 
 fs/bad_inode.c                    |    1 
 include/linux/fs.h                |    1 
 include/linux/mm.h                |    4 
 include/linux/swap.h              |    6 
 mm/madvise.c                      |   15 
 mm/memcontrol.c                   |   17 
 mm/shmem.c                        |  513 +++++++++++++++++++++++++---
 mm/swapfile.c                     |    2 
 mm/truncate.c                     |   25 -
 12 files changed, 500 insertions(+), 107 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
