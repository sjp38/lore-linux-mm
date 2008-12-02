Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB2JOFgA008997
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 14:24:15 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB2JOlGe172076
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 14:24:47 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB2JOkTc021342
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 14:24:46 -0500
Subject: Re: [Bug 12134] New: can't shmat() 1GB hugepage segment from
 second process more than one time
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20081201181459.49d8fcca.akpm@linux-foundation.org>
References: <bug-12134-27@http.bugzilla.kernel.org/>
	 <20081201181459.49d8fcca.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 02 Dec 2008 13:24:40 -0600
Message-Id: <1228245880.13482.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, starlight@binnacle.cx, Andy Whitcroft <apw@shadowen.org>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 18:14 -0800, Andrew Morton wrote:
> > can't shmat() 1GB hugepage segment from second process more than one time
> > 
> > Steps to reproduce:

starlight@binnacle.cx:  I need more information to reproduce this bug.
Please read on.

I've tried these steps and haven't been able to reproduce.  Are these
reproduction steps actually a description of what a more complex program
is doing, or have you reproduced this with simple C programs that
implement nothing more than the instructions provided in this bug?

It would make it easier to diagnose this if you could provide a simple C
program that causes the bad behavior.

> > 
> > create 1GB or more hugepage shmget/shmat segment
> > attached at explicit virtual address 0x4_00000000

You must mean either 0x400000000 or 0x4000000000; please clarify.  (I
tried both addresses and was unable to reproduce.  Are you touching any
of the pages in the shared memory segment with this process?  What flags
are you passing to shmget and shmat?  Could you provide an strace for
each program run?

> > run another program that attaches segment

Does this second program do anything besides attaching the segment (ie.
faulting any of the huge pages)?

> > run it again, fails
> > 
> > eventually get attached 'dmesg' output
> > 
> > works fine under RHEL 4.6
> > 
> > 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
