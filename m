Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iB8Mp6GM022639
	for <linux-mm@kvack.org>; Wed, 8 Dec 2004 17:51:06 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iB8Mp11m284880
	for <linux-mm@kvack.org>; Wed, 8 Dec 2004 17:51:06 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iB8MotMs016811
	for <linux-mm@kvack.org>; Wed, 8 Dec 2004 17:50:56 -0500
Date: Wed, 08 Dec 2004 14:50:07 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Anticipatory prefaulting in the page fault handler V1
Message-ID: <156610000.1102546207@flay>
In-Reply-To: <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain><Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com><Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org><Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com><Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org><Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com><Pine.LNX.4.58.0412011608500.22796@ppc970.osdl.org> <41AEB44D.2040805@pobox.com><20041201223441.3820fbc0.akpm@osdl.org> <41AEBAB9.3050705@pobox.com><20041201230217.1d2071a8.akpm@osdl.org> <179540000.1101972418@[10.10.2.4]><41AEC4D7.4060507@pobox.com> <20041202101029.7fe8b303.cliffw@osdl.org> <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, nickpiggin@yahoo.com.au
Cc: Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> The page fault handler for anonymous pages can generate significant overhead
> apart from its essential function which is to clear and setup a new page
> table entry for a never accessed memory location. This overhead increases
> significantly in an SMP environment.
> 
> In the page table scalability patches, we addressed the issue by changing
> the locking scheme so that multiple fault handlers are able to be processed
> concurrently on multiple cpus. This patch attempts to aggregate multiple
> page faults into a single one. It does that by noting
> anonymous page faults generated in sequence by an application.
> 
> If a fault occurred for page x and is then followed by page x+1 then it may
> be reasonable to expect another page fault at x+2 in the future. If page
> table entries for x+1 and x+2 would be prepared in the fault handling for
> page x+1 then the overhead of taking a fault for x+2 is avoided. However
> page x+2 may never be used and thus we may have increased the rss
> of an application unnecessarily. The swapper will take care of removing
> that page if memory should get tight.

I tried benchmarking it ... but processes just segfault all the time. 
Any chance you could try it out on SMP ia32 system?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
