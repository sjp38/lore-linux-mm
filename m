Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 005F96B0204
	for <linux-mm@kvack.org>; Thu, 13 May 2010 05:49:46 -0400 (EDT)
Received: by pva4 with SMTP id 4so462304pva.14
        for <linux-mm@kvack.org>; Thu, 13 May 2010 02:49:45 -0700 (PDT)
From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 0/9] mm: generic adaptive large memory allocation APIs
Date: Thu, 13 May 2010 17:49:07 +0800
Message-Id: <1273744147-7594-1-git-send-email-xiaosuo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, "James E.J. Bottomley" <James.Bottomley@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, Changli Gao <xiaosuo@gmail.com>
List-ID: <linux-mm.kvack.org>

generic adaptive large memory allocation APIs

kv*alloc are used to allocate large contiguous memory and the users don't mind
whether the memory is physically or virtually contiguous. The allocator always
try its best to allocate physically contiguous memory first.

In this patch set, some APIs are introduced: kvmalloc(), kvzalloc(), kvcalloc(),
kvrealloc(), kvfree() and kvfree_inatomic().

Some code are converted to use the new generic APIs instead.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 drivers/infiniband/hw/ehca/ipz_pt_fn.c |   22 +-----
 drivers/net/cxgb3/cxgb3_defs.h         |    2 
 drivers/net/cxgb3/cxgb3_offload.c      |   31 ---------
 drivers/net/cxgb3/l2t.c                |    4 -
 drivers/net/cxgb4/cxgb4.h              |    3 
 drivers/net/cxgb4/cxgb4_main.c         |   37 +----------
 drivers/net/cxgb4/l2t.c                |    2 
 drivers/scsi/cxgb3i/cxgb3i_ddp.c       |   12 +--
 drivers/scsi/cxgb3i/cxgb3i_ddp.h       |   26 -------
 drivers/scsi/cxgb3i/cxgb3i_offload.c   |    6 -
 fs/ext4/super.c                        |   21 +-----
 fs/file.c                              |  109 ++++-----------------------------
 include/linux/mm.h                     |   31 +++++++++
 include/linux/vmalloc.h                |    1 
 kernel/cgroup.c                        |   47 +-------------
 kernel/relay.c                         |   35 ----------
 mm/nommu.c                             |    6 +
 mm/util.c                              |  104 +++++++++++++++++++++++++++++++
 mm/vmalloc.c                           |   14 ++++
 19 files changed, 207 insertions(+), 306 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
