Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9PLVY7I009733
	for <linux-mm@kvack.org>; Wed, 25 Oct 2006 17:31:34 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9PLVGMV260532
	for <linux-mm@kvack.org>; Wed, 25 Oct 2006 17:31:19 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9PLVFt7020314
	for <linux-mm@kvack.org>; Wed, 25 Oct 2006 17:31:15 -0400
Subject: Re: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20061025062610.GB2330@localhost.localdomain>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0610250335530.30678@blonde.wat.veritas.com>
	 <20061025062610.GB2330@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 25 Oct 2006 16:31:14 -0500
Message-Id: <1161811874.18662.131.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: npiggin@suse.de, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-10-25 at 16:26 +1000, David Gibson wrote:
> Correct these by moving the i_size check to before the allocation of a
> new page.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

I have some early patches which do this very same thing albeit for a
different reason.  I was looking to create a proper ->nopage() operation
for hugetlbfs and quarantine fs things (inodes included) to
fs/hugetlbfs/inode.c.  The added advantage is hugetlb_[get/put]_quota()
calls could also be isolated to fs/hugetlbfs/inode.c.  Unfortunately
this was all held up by Nick Piggin's awesome ->fault() work.  Speaking
of which, could we just use VM_FAULT_RETRY semantics to handle the
i_size check that patch in the parent email removes?   [ Obviously not
for 2.6.19 :-) ]

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
