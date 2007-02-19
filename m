Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l1JJY9UH030698
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 14:34:09 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JJYqGo518994
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 12:34:52 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JJYqeQ005437
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 12:34:52 -0700
Subject: Re: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1171910581.3531.89.camel@laptopd505.fenrus.org>
References: <20070219183123.27318.27319.stgit@localhost.localdomain>
	 <1171910581.3531.89.camel@laptopd505.fenrus.org>
Content-Type: text/plain
Date: Mon, 19 Feb 2007 13:34:51 -0600
Message-Id: <1171913691.22940.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-02-19 at 19:43 +0100, Arjan van de Ven wrote:
> On Mon, 2007-02-19 at 10:31 -0800, Adam Litke wrote:
> > The page tables for hugetlb mappings are handled differently than page tables
> > for normal pages.  Rather than integrating multiple page size support into the
> > main VM (which would tremendously complicate the code) some hooks were created.
> > This allows hugetlb special cases to be handled "out of line" by a separate
> > interface.
> 
> ok it makes sense to clean this up.. what I don't like is that there
> STILL are all the double cases... for this to work and be worth it both
> the common case and the hugetlb case should be using the ops structure
> always! Anything else and you're just replacing bad code with bad
> code ;(

Hmm.  Do you think everyone would support an extra pointer indirection
for every handle_pte_fault() call?  If not, then I definitely wouldn't
mind creating a default_pagetable_ops and calling into that.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
