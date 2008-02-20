Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1KEsdTB012647
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 09:54:39 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1KEqgv6234012
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 09:52:42 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1KEqgiD015177
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 09:52:42 -0500
Subject: Re: [PATCH] hugetlb: ensure we do not reference a surplus page
	after handing it to buddy
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080219153037.ec336fd2.akpm@linux-foundation.org>
References: <1203445688.0@pinky>
	 <1203446512.11987.36.camel@localhost.localdomain>
	 <20080219153037.ec336fd2.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 20 Feb 2008 08:59:34 -0600
Message-Id: <1203519574.11987.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Nishanth Aravamudan <nacc@us.ibm.com>, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-19 at 15:30 -0800, Andrew Morton wrote:
> On Tue, 19 Feb 2008 12:41:51 -0600 Adam Litke <agl@us.ibm.com> wrote:
> 
> > Indeed.  I'll take credit for this thinko...
> > 
> > On Tue, 2008-02-19 at 18:28 +0000, Andy Whitcroft wrote:
> > > When we free a page via free_huge_page and we detect that we are in
> > > surplus the page will be returned to the buddy.  After this we no longer
> > > own the page.  However at the end free_huge_page we clear out our mapping
> > > pointer from page private.  Even where the page is not a surplus we
> > > free the page to the hugepage pool, drop the pool locks and then clear
> > > page private.  In either case the page may have been reallocated.  BAD.
> > > 
> > > Make sure we clear out page private before we free the page.
> > > 
> > > Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> > 
> > Acked-by: Adam Litke <agl@us.ibm.com>
> 
> Was I right to assume that this is also needed in 2.6.24.x?

Yep.  Thanks Andrew.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
