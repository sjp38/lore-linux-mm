From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/6] writeback cleanups and trivial fixes
Date: Sun, 11 Jul 2010 10:06:56 +0800
Message-ID: <20100711020656.340075560@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OXmQt-0002Hu-EW
	for glkm-linux-mm-2@m.gmane.org; Sun, 11 Jul 2010 04:38:19 +0200
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 210F66B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 22:38:11 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Andrew,

Here are some writeback cleanups to avoid unnecessary calculation overheads,
and relative simple bug fixes.

The patch applies to latest linux-next tree. The mmotm tree will need rebase
to include commit 32422c79 (writeback: Add tracing to balance_dirty_pages)
in order to avoid merge conflicts.

[PATCH 1/6] writeback: take account of NR_WRITEBACK_TEMP in balance_dirty_pages()
[PATCH 2/6] writeback: reduce calls to global_page_state in balance_dirty_pages()
[PATCH 3/6] writeback: avoid unnecessary calculation of bdi dirty thresholds

[PATCH 4/6] writeback: dont redirty tail an inode with dirty pages
[PATCH 5/6] writeback: fix queue_io() ordering
[PATCH 6/6] writeback: merge for_kupdate and !for_kupdate cases

 fs/fs-writeback.c         |   68 ++++-----------
 include/linux/writeback.h |    5 -
 mm/backing-dev.c          |    3 
 mm/page-writeback.c       |  158 ++++++++++++++----------------------
 4 files changed, 89 insertions(+), 145 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
