Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 72F926B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 22:44:56 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o6L2iqm4031470
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:44:52 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by wpaz29.hot.corp.google.com with ESMTP id o6L2ipV0017016
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:44:51 -0700
Received: by pvh1 with SMTP id 1so3306183pvh.41
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:44:51 -0700 (PDT)
Date: Tue, 20 Jul 2010 19:44:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 0/6] remove dependency on __GFP_NOFAIL for failable
 allocations
Message-ID: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Steve Wise <swise@chelsio.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Jan Kara <jack@suse.cz>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Roland Dreier <rolandd@cisco.com>, Jens Axboe <jens.axboe@oracle.com>, Bob Peterson <rpeterso@redhat.com>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset removes __GFP_NOFAIL from various allocations when those 
callers have error handling or the subsystem doesn't absolutely require
success.

This is the first phase of two for the total removal of __GFP_NOFAIL:
this patchset is intended to fix obvious users of __GFP_NOFAIL that are
already failable or otherwise unnecessary.  The second phase will replace
__GFP_NOFAIL with a different gfp which will use all of the page
allocator's resources (direct reclaim, compaction, and the oom killer)
to free memory but not infinitely loop in the allocator itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
