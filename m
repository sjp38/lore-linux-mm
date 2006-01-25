Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0PJmVqY007063
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 14:48:31 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0PJokfL164634
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 12:50:46 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0PJmUrP012763
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 12:48:30 -0700
Subject: [patch 0/9] Critical Mempools
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
Content-Type: text/plain
Date: Wed, 25 Jan 2006 11:39:52 -0800
Message-Id: <1138217992.2092.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--
The following is a new patch series designed to solve the same problems as the
"Critical Page Pool" patches that were sent out in December.  I've tried to
incorporate as much of the feedback that I received as possible into this new,
redesigned version.

Rather than inserting hooks directly into the page allocator, I've tried to
piggyback on the existing mempools infrastructure.  What I've done is created
a new "common" mempool allocator for whole pages.  I've also made some changes
to the mempool code to add more NUMA awareness.  Lastly, I've made some
changes to the slab allocator to allow a single mempool to act as the critical
pool for an entire subsystem.  All of these changes should be completely
transparent to existing users of mempools and the slab allocator.

Using this new approach, a subsystem can create a mempool and then pass a
pointer to this mempool on to all its slab allocations.  Anytime one of its
slab allocations needs to allocate memory that memory will be allocated
through the specified mempool, rather than through alloc_pages_node() directly.

Feedback on these patches (against 2.6.16-rc1) would be greatly appreciated.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
