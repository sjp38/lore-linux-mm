Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9T03pvi030447
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 20:03:51 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9T03pk9204464
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 18:03:51 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9T03oIF002691
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 18:03:51 -0600
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051028184235.GC8514@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <20051028034616.GA14511@ccure.user-mode-linux.org>
	 <43624F82.6080003@us.ibm.com>
	 <20051028184235.GC8514@ccure.user-mode-linux.org>
Content-Type: text/plain
Date: Fri, 28 Oct 2005 17:03:21 -0700
Message-Id: <1130544201.23729.167.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-10-28 at 14:42 -0400, Jeff Dike wrote:
> On Fri, Oct 28, 2005 at 09:19:14AM -0700, Badari Pulavarty wrote:
> > My touch tests so far, doesn't really verify data after freeing. I was
> > thinking about writing cases. If I can use UML to do it, please send it
> > to me. I would rather test with real world case :)
> 
> Grab and unpack http://www.user-mode-linux.org/~jdike/truncate.tar.bz2

Here is the update on the patch.

I found few bugs in my shmem_truncate_range() (surprise!!)
	- BUG_ON(subdir->nr_swapped > offset);
	- freeing up the "subdir" while it has some more entries
	swapped.

I wrote some tests to force swapping and working out the bugs.
I haven't tried your test yet, since its kind of intimidating :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
