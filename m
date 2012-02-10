Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id AF0086B002C
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:42:22 -0500 (EST)
Received: by bkty12 with SMTP id y12so3584330bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:42:20 -0800 (PST)
Subject: [PATCH 0/4] shmem: radix-tree cleanups and swapoff optimizations
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 10 Feb 2012 23:42:18 +0400
Message-ID: <20120210193249.6492.18768.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

Here some shmem patches related to the radix-tree iterator patchset,
they cleans radix-tree usage in shmem and notably optimizes swapoff operation.
Last patch is slightly off-topic, but it shares test results with previous patch.

---

Konstantin Khlebnikov (4):
      shmem: simlify shmem_unlock_mapping
      shmem: tag swap entries in radix tree
      shmem: use radix-tree iterator in shmem_unuse_inode()
      mm: use swap readahead at swapoff


 include/linux/radix-tree.h |    1 
 lib/radix-tree.c           |   93 --------------------------------------------
 mm/shmem.c                 |   60 ++++++++++++++++++++--------
 mm/swapfile.c              |    3 -
 4 files changed, 44 insertions(+), 113 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
