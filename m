Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 53F116B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 04:02:38 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/4] Get rid of iput() from flusher thread
Date: Fri,  9 Mar 2012 10:02:24 +0100
Message-Id: <1331283748-12959-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>


  Hi,

  this patch set changes writeback_sb_inodes() to avoid iput() which might
be problematic (see patch 4 which tries to summarize our email discussions)
for some filesystems.

  Patches 1 and 2 are trivial mostly unrelated fixes (Fengguang, can you can
take these and merge them right away please?). Patch 3 is a preparatory code
reshuffle and patch 4 removes the __iget() / iput() from flusher thread.

  As a side note, your patches to offload writeback from kswapd to flusher
thread then won't need iget/iput either if we pass page references as we talked
so that should resolve most of the concerns.

  What do you think guys?

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
