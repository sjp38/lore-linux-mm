Received: from ext1.nea-fast.com (ext1.nea-fast.com [208.241.120.230])
	by int2.nea-fast.com (8.8.8+Sun/8.8.8) with ESMTP id SAA15539
	for <linux-mm@kvack.org>; Sun, 10 Oct 1999 18:09:52 -0400 (EDT)
Received: from pobox.com (adsl-77-228-233.atl.bellsouth.net [216.77.228.233])
	by ext1.nea-fast.com (8.8.8+Sun/8.8.8) with ESMTP id SAA12233
	for <linux-mm@kvack.org>; Sun, 10 Oct 1999 18:13:44 -0400 (EDT)
Message-ID: <38010EAB.ACC45162@pobox.com>
Date: Sun, 10 Oct 1999 18:09:47 -0400
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: simple slab alloc question
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kmalloc seems to allocate against various kmem_cache sizes: 32,
64...1024...65536...

Does this mean that allocations of various sizes are stored in different
"buckets"?  Would that not reduce fragmentation and the need for a zone
allocator?

Enlightenment from MM gurus appreciated :)

Regards,

	Jeff




-- 
Custom driver development	|    Never worry about theory as long
Open source programming		|    as the machinery does what it's
				|    supposed to do.  -- R. A. Heinlein
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
