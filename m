Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9D96A8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:25:51 -0500 (EST)
Date: Tue, 22 Feb 2011 22:25:43 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: IO-less dirty throttling V6 results available
Message-ID: <20110222142543.GA13132@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan.kim@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, Sorin Faibish <sfaibish@emc.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Dear all,

I've finally stabilized the dirty throttling V6 control algorithms
with good behavior in all the tests I run, including low/high memory
profiles, HDD/SSD/UKEY, JBOD/RAID0 and all major filesystems. It took
near two months to redesign and sort out the rough edges since V5,
sorry for the long delay!

It will take several more days to prepare the patches. Before that I'd
like to release a combined patch for 3rd party testing and some test
results for early evaluations:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6

Expect more introductions tomorrow :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
