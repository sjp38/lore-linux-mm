Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9A85A6B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 22:58:37 -0500 (EST)
Date: Thu, 13 Jan 2011 11:58:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 01/35] writeback: enabling gate limit for light dirtied
 bdi
Message-ID: <20110113035831.GA9970@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150326.480108782@intel.com>
 <20110112214303.GC14260@quack.suse.cz>
 <20110113034401.GB7840@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110113034401.GB7840@localhost>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> sigh.. I've been hassled a lot by the possible disharmonies between
> the bdi/global dirty limits.
> 
> One example is the below graph, where the bdi dirty pages are
> constantly exceeding the bdi dirty limit. The root cause is,
> "(dirty + background) / 2" may be close to or even exceed
> bdi_dirty_limit. 

When exceeded, the task will not get throttled at all at some time,
and get hard throttled at other times.

> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/256M/ext3-2dd-1M-8p-191M-2.6.37-rc5+-2010-12-09-13-42/dirty-pages-200.png

This graph is more obvious. However I'm no longer sure they are the
exact graphs that are caused by "(dirty + background) / 2 > bdi_dirty_limit",
which evaluates to TRUE after I do "[PATCH 02/35] writeback: safety
margin for bdi stat error", which lowered bdi_dirty_limit by 1-2MB in
that test case.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/256M/btrfs-1dd-1M-8p-191M-2.6.37-rc5+-2010-12-09-14-35/dirty-pages-200.png

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
