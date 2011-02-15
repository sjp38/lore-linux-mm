Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 724978D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 12:05:40 -0500 (EST)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1FGs8TZ007512
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 09:54:08 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1FH5VwB102394
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 10:05:31 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1FH38Os031576
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 10:03:08 -0700
Subject: Re: [PATCH 0/5] fix up /proc/$pid/smaps to not split huge pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110215170152.GF5935@random.random>
References: <20110209195406.B9F23C9F@kernel>
	 <20110215165510.GA2550@mgebm.net>  <20110215170152.GF5935@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 15 Feb 2011 09:05:25 -0800
Message-ID: <1297789525.9829.9616.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Eric B Munson <emunson@mgebm.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>

On Tue, 2011-02-15 at 18:01 +0100, Andrea Arcangeli wrote:
> > The entire mapping is contained in a THP but the
> > KernelPageSize shows 4kb.  For cases where the mapping might
> > have mixed page sizes this may be okay, but for this
> > particular mapping the 4kb page size is wrong.
> 
> I'm not sure this is a bug, if the mapping grows it may become 4096k
> but the new pages may be 4k. There's no such thing as a
> vma_mmu_pagesize in terms of hugepages because we support graceful
> fallback and collapse/split on the fly without altering the vma. So I
> think 4k is correct here

How about we bump MMUPageSize for mappings that are _entirely_ huge
pages, but leave it at 4k for mixed mappings?  Anyone needing more
detail than that can use the new AnonHugePages count.

KernelPageSize is pretty ambiguous, and we could certainly make the
argument that the kernel is or can still deal with things in 4k blocks.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
