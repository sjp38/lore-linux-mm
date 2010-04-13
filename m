Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 75E3C6B01F5
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 21:20:45 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 0/2] Context sensitive memory shrinker support
Date: Tue, 13 Apr 2010 10:24:13 +1000
Message-Id: <1271118255-21070-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Recently I made the XFS inode reclaim operate entirely in the background for
both clean and dirty inodes as it simplified the code a lot and is somewhat
more efficient. Unfortunately, there are some workloads where the
background reclaim is not freeing memory fast enough, so the reclaim needs an
extra push when memory is low.

The inode caches are per-filesystem on XFS, so to make effective use of the
shrinker callbacks when memory is low, we need a context to be passed through
the shrinker to give us the filesystem context to run the reclaim from. The
two patches introduce the shrinker context and implement the XFS inode reclaim
shrinkers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
