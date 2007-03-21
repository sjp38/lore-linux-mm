Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2LKQtKW028071
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 16:26:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2LKQkg5070772
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 14:26:49 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2LKQkDm009063
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 14:26:46 -0600
Subject: Re: pagetable_ops: Hugetlb character device example
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <200703211951.l2LJpVPS020364@turing-police.cc.vt.edu>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
	 <1174506228.21684.41.camel@localhost.localdomain>
	 <200703211951.l2LJpVPS020364@turing-police.cc.vt.edu>
Content-Type: text/plain
Date: Wed, 21 Mar 2007 15:26:44 -0500
Message-Id: <1174508804.21684.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-21 at 15:51 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Wed, 21 Mar 2007 14:43:48 CDT, Adam Litke said:
> > The main reason I am advocating a set of pagetable_operations is to
> > enable the development of a new hugetlb interface.
> 
> Do you have an exit strategy for the *old* interface?

Not really.  Hugetlbfs needs to be kept around for a number of reasons.
It was designed to support MAP_SHARED mappings and IPC shm segments.  It
is probably still the best interface for those jobs.  Of course
hugetlbfs has lots of users so we must preserve the interface for them.

But... once hugetlbfs is abstracted behind pagetable_operations, you
would have the option of configuring it out of the kernel without losing
access to huge pages by other means (such as the character device).

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
