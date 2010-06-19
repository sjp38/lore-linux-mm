Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 568BE6B01C4
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 20:30:55 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 0/3] writeback visibility
Date: Fri, 18 Jun 2010 17:30:12 -0700
Message-Id: <1276907415-504-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

Debugging writeback issues and tuning an application's writeback activity is
easier when the activity is visible.  With large clusters, classifying
and root causing writeback problems has been a big headache. This patch
series contains a series of patches that our team has been using to start
getting a handle on writeback behaviour. These changes should be helpful
for single system maintainers also. It's still a big headache.

Once these changes are reviewed I will make sure the Documentation files
are updated, but I expect some back and forth first.

Michael Rubin (3):
  writeback: Creating /sys/kernel/mm/writeback/writeback
  writeback: per bdi monitoring
  writeback: tracking subsystems causing writeback

 drivers/base/node.c         |   14 +++++
 fs/buffer.c                 |    2 +-
 fs/fs-writeback.c           |   28 +++++++--
 fs/nilfs2/segment.c         |    4 +-
 fs/sync.c                   |    2 +-
 include/linux/backing-dev.h |    9 +++
 include/linux/mmzone.h      |    2 +
 include/linux/writeback.h   |   50 +++++++++++++++-
 mm/backing-dev.c            |  137 ++++++++++++++++++++++---------------------
 mm/mm_init.c                |  122 ++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c         |   18 ++++--
 mm/vmscan.c                 |    3 +-
 mm/vmstat.c                 |    2 +
 13 files changed, 311 insertions(+), 82 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
