Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0BN3RLJ012212
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 18:03:27 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0BN3R4f128236
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 18:03:27 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0BN3RLn005990
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 18:03:27 -0500
Subject: Re: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20060111225202.GE9091@holomorphy.com>
References: <1136920951.23288.5.camel@localhost.localdomain>
	 <1137016960.9672.5.camel@localhost.localdomain>
	 <1137018263.9672.10.camel@localhost.localdomain>
	 <20060111225202.GE9091@holomorphy.com>
Content-Type: text/plain
Date: Wed, 11 Jan 2006 17:03:25 -0600
Message-Id: <1137020606.9672.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-01-11 at 14:52 -0800, William Lee Irwin III wrote:
> On Wed, Jan 11, 2006 at 04:24:23PM -0600, Adam Litke wrote:
> > My only concern is if I am using the correct lock for the job here.
> 
> ->i_lock looks rather fishy. It may have been necessary when ->i_blocks
> was used for nefarious purposes, but without ->i_blocks fiddling, it's
> not needed unless I somehow missed the addition of some custom fields
> to hugetlbfs inodes and their modifications by any of these functions.

Nope, all the i_blocks stuff is gone.  I was just looking for a
spin_lock for serializing all allocations for a particular hugeltbfs
file and i_lock seemed to fit that bill.  It could be said, however,
that the locking strategy used in the patch protects a section of code,
not a data structure (which can be a bad idea).  Any thoughts on a less
"fishy" locking strategy for this case?

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
