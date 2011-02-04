Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 961308D0040
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 11:45:25 -0500 (EST)
Date: Fri, 4 Feb 2011 17:42:22 +0100
From: Jan Kara <jack@suse.cz>
Subject: [LSF/MM TOPIC] Writeback - current state and future
Message-ID: <20110204164222.GG4104@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linuxfoundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

  Hi,

  I'd like to have one session about writeback. The content would highly
depend on the current state of things but on a general level, I'd like to
quickly sum up what went into the kernel (or is mostly ready to go) since
last LSF (handling of background writeback, livelock avoidance), what is
being worked on - IO-less balance_dirty_pages() (if it won't be in the
mostly done section), what other things need to be improved (kswapd
writeout, writeback_inodes_sb_if_idle() mess, come to my mind now)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
