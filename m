Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E28736B0087
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 21:44:55 -0500 (EST)
Message-Id: <20101110023500.404859581@intel.com>
Date: Wed, 10 Nov 2010 10:35:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/5] writeback livelock fixes v2
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew,

Here are the writeback livelock fixes (patch 3, 4) from Jan Kara.

changes from v1:

- collect the various changelog and comment changes from email discussions


 [PATCH 1/5] writeback: integrated background writeback work
 [PATCH 2/5] writeback: trace wakeup event for background writeback
 [PATCH 3/5] writeback: stop background/kupdate works from livelocking other works
 [PATCH 4/5] writeback: avoid livelocking WB_SYNC_ALL writeback
 [PATCH 5/5] writeback: check skipped pages on WB_SYNC_ALL

 fs/fs-writeback.c                |  105 +++++++++++++++++++++++------
 include/trace/events/writeback.h |    1 
 2 files changed, 87 insertions(+), 19 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
