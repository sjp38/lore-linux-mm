Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB5HH8Xk030676
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 12:17:08 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB5HHfiK178972
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 12:17:41 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB5IHoWF026575
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 13:17:51 -0500
Subject: Re: [Bug 12134] New: can't shmat() 1GB hugepage segment  from
 second process more than one time
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <6.2.5.6.2.20081203221021.01cf8e88@binnacle.cx>
References: <bug-12134-27@http.bugzilla.kernel.org/>
	 <20081201181459.49d8fcca.akpm@linux-foundation.org>
	 <1228245880.13482.19.camel@localhost.localdomain>
	 <6.2.5.6.2.20081203221021.01cf8e88@binnacle.cx>
Content-Type: text/plain
Date: Fri, 05 Dec 2008 11:17:30 -0600
Message-Id: <1228497450.13428.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: starlight@binnacle.cx
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, Andy Whitcroft <apw@shadowen.org>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-12-03 at 22:15 -0500, starlight@binnacle.cx wrote:
> At 13:24 12/2/2008 -0600, Adam Litke wrote:
> >starlight@binnacle.cx:  I need more information
> >to reproduce this bug.
> 
> I'm too swamped to build a test-case, but here are straces
> that show the relevant system calls and the failure.

Starlight,

Thanks for the strace output.  As I suspected, this is more complex than
it first appeared.  There are several hugetlb shared memory segments
involved.  Couple that with threading and an interesting approach to
mlocking the address space and I've got a very difficult to reproduce
scenario.  Is it possible/practical for me to have access to your
program?  If so, I could quickly bisect the kernel and identify the
guilty patch.  Without the program, I am left stabbing in the dark.
Could you try on a 2.6.18 kernel to see if it works or not?  Thanks.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
