Received: (from sct@localhost)
	by dukat.scot.redhat.com (8.9.3/8.9.3) id SAA01805
	for linux-mm@kvack.org; Tue, 25 Apr 2000 18:22:24 +0100
Resent-Message-Id: <200004251722.SAA01805@dukat.scot.redhat.com>
Date: Tue, 25 Apr 2000 05:03:01 -0700
Message-Id: <200004251203.FAA04709@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
Subject: 2.3.x swap cache seems to be a big leak
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

__delete_from_swap_cache depends upon remove_inode_page doing
a put_page or similar to kill the reference of the swap cache
itself

We changed remove_inode_page during the page cache rewrite such
that is no longer puts the page, the caller does.

If I am right, this causes swap cache pages to never go away.

So if I haven't missed something clever going on here, this would
explain a lot of problems people have reported with swapping making
their machines act weird and eventually run out of ram.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
