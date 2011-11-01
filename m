Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 64DCC6B002D
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 03:43:55 -0400 (EDT)
Date: Tue, 1 Nov 2011 15:43:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: writeback tree status (for 3.2 merge window)
Message-ID: <20111101074347.GA23644@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Curt Wohlgemuth <curtw@google.com>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tang Feng <feng.tang@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

Hi,

There are 3 patchsets sitting in the writeback tree.

        1) IO-less dirty throttling v12
        https://github.com/fengguang/linux/commits/dirty-throttling-v12

        2) writeback reasons tracing from Curt Wohlgemuth
        https://github.com/fengguang/linux/commits/writeback-reason

        3) writeback queuing changes from Jan Kara and me
        https://github.com/fengguang/linux/commits/requeue-io-wait

They have been merged into this branch testing in linux-next for a while:

https://github.com/fengguang/linux/commits/writeback-for-next

Since (3) still has an unresolved issue (detailed in the below
links), it looks better to hold it back for this merge window.

http://permalink.gmane.org/gmane.linux.kernel/1206315
http://permalink.gmane.org/gmane.linux.kernel/1206316

The patches from (1,2) together with 2 tracing patches essential for
debugging (1) have been pushed to the "writeback-for-linus" branch:

        http://git.kernel.org/?p=linux/kernel/git/wfg/linux.git;a=shortlog;h=refs/heads/writeback-for-linus

If no objections, I'll send a pull request to Linus soon.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
