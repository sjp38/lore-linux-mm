Date: Wed, 2 Oct 2002 03:00:15 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: my VM TODO list
Message-ID: <20021002100015.GC31587@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: riel@surriel.com
List-ID: <linux-mm.kvack.org>

-------

(1) hugetlbfs
	written, needs to return -EINVAL higher up instead of BUG_ON()
	lower down, and make shm bits DTRT.

(2) pagetable reclaim
	Figured out where the pmd weirdness happens and restarted
	lookups, need to find a spot to go blow them away, when
	to do it, and maybe do something about private anonymous.

(3) help out with pagetable sharing
	Not sure what's going on there.

-----
long-since vetoed/hated/whatever wishlist items omitted

Wishlist:
--------
(1) x86 page clustering
	Pretending 1 << order pte's are a single pte is easy.
	IA64 appears to have subpage mmapping code to cherry pick
	for 4KB compatibility, possibly omit it if it's a problem.

Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
