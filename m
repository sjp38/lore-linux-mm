Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1910E6B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 19:23:05 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
Subject: FS-Cache VM-affecting patch review
Date: Thu, 02 Apr 2009 00:23:11 +0100
Message-ID: <29600.1238628191@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <peterz@infradead.org>
Cc: dhowells@redhat.com, linux-mm@kvack.org, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>


Hi Nick, Hugh, Peter,

I don't suppose I could persuade you to review some of my FS-Cache patches?
specifically patches 05, 06, 22 and 23 from the set I've just posted.

[PATCH 05/43] FS-Cache: Release page->private after failed readahead
[PATCH 06/43] FS-Cache: Recruit a couple of page flags for cache management
[PATCH 22/43] CacheFiles: Add a hook to write a single page of data to an inode
[PATCH 23/43] CacheFiles: Permit the page lock state to be monitored

Thanks,
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
