Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC0A8D0040
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 14:06:48 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [LSF/MM TOPIC] memcg aware writeback
Date: Fri, 04 Feb 2011 11:06:33 -0800
Message-ID: <xr937hdf39hi.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linuxfoundation.org
Cc: linux-mm@kvack.org

In the MM Summit I would like to discuss pending memcg dirty limits changes and
especially how they will interact with writeback.

Once we have memcg dirty limits, we will face a new issue.  When a memcg
dirty limit is crossed, writeback needs to bring the memcg back under
its dirty limit.  Currently, writeback is unaware of memory controller.
Therefore writeback assumes that all dirty inodes are candidates for
memcg writeback.  Our experience in Google production shows that doing
global (non cgroup aware) writeback substantially reduces isolation
between memory-hungry jobs.

If there was a way for memcg writeback to either avoid irrelevant inodes
or avoid irrelevant pages, then better isolation could be achieved.

We have been working on various designs to allow either page or inode
level filtering in the writeback code to achieve memcg-aware writeback.
I would like to have a discussion about these designs and see what
interest there is in this topic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
