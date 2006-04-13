Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3DK6xIP008297
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 16:06:59 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3DK6nJJ190720
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 16:06:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k3DK6nY9008502
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 16:06:49 -0400
Subject: Re: [RFD hugetlbfs] strict accounting and wasteful reservations
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20060413200143.GA13729@localhost.localdomain>
References: <1144949802.10795.99.camel@localhost.localdomain>
	 <20060413191801.GA9195@localhost.localdomain>
	 <1144957873.10795.110.camel@localhost.localdomain>
	 <20060413200143.GA13729@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 13 Apr 2006 15:06:44 -0500
Message-Id: <1144958804.10795.111.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: akpm@osdl.org, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-04-13 at 21:01 +0100, 'David Gibson' wrote:
> > We are thinking about switching the implementation of the ELF segment
> > remapping code to store all of the remapped segments in one hugetlbfs
> > file.  That way we have one hugetlb file per executable.  This makes
> > managing the segments much easier, especially when doing things like
> > global sharing.  When doing this, we'd like the file offset to
> > correspond to the virtual address of the mapped segment.  So I admit
> > that altering the kernel behavior helps libhugetlbfs, but I think my
> > second justification above is even more important.  I like removing
> > anomalies from hugetlbfs whenever possible.
> 
> Hrm... I'm not entirely convinced attempting to directly map vaddr to
> file offset is a good idea.  But give it a shot, I guess.

It works, but just wastes a ton of huge pages in the process.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
