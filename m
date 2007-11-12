Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lACEqOrP031490
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 09:52:24 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lACEqGLM104890
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 07:52:18 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lACEqGT4016292
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 07:52:16 -0700
Subject: Re: [patch] hugetlb: fix i_blocks accounting
From: aglitke <agl@us.ibm.com>
In-Reply-To: <b040c32a0711091734s13d4ffcaj4123dd27d24bf330@mail.gmail.com>
References: <b040c32a0711082343t2b94b495r1608d99ec0e28a4c@mail.gmail.com>
	 <1194617837.14675.45.camel@localhost.localdomain>
	 <b040c32a0711090942x45e89356kcc7d3282b2dedcb2@mail.gmail.com>
	 <1194631797.14675.49.camel@localhost.localdomain>
	 <20071109171613.3b11b581.akpm@linux-foundation.org>
	 <b040c32a0711091734s13d4ffcaj4123dd27d24bf330@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 12 Nov 2007 08:53:44 -0600
Message-Id: <1194879224.14675.61.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-09 at 17:34 -0800, Ken Chen wrote:
> On Nov 9, 2007 5:16 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Fri, 09 Nov 2007 12:09:57 -0600
> > aglitke <agl@us.ibm.com> wrote:
> >
> > > Thanks for that explanation.  It makes complete sense to me now.
> >
> > We have a distressing number of hugetlb patches here:
> >
> > hugetlb-follow_hugetlb_page-for-write-access.patch
> > hugetlb-allow-sticky-directory-mount-option.patch
> > hugetlb-split-alloc_huge_page-into-private-and-shared-components.patch
> > hugetlb-split-alloc_huge_page-into-private-and-shared-components-checkpatch-fixes.patch
> > hugetlb-fix-quota-management-for-private-mappings.patch
> > hugetlb-debit-quota-in-alloc_huge_page.patch
> > hugetlb-allow-bulk-updating-in-hugetlb__quota.patch
> > hugetlb-enforce-quotas-during-reservation-for-shared-mappings.patch
> > mm-hugetlbc-make-a-function-static.patch
> > hugetlb-fix-i_blocks-accounting.patch
> >
> > (all available at http://userweb.kernel.org/~akpm/mmotm/)
> >
> > Could we please put heads together and work out which of these need to go
> > into 2.6.24?  And 2.6.23, come to that...
> 
> I would vote all of it.  If we really need to prioritize them, I would
> list them in the following order:

I agree that all of them are ready to go for 2.6.24.  I don't think #3
(follow_hugetlb_page fix) meets the criteria for a -stable patch
otherwise I'd have suggested it go forth into 2.6.23.  

> 1. fs quota fix:
>    hugetlb-split-alloc_huge_page-into-private-and-shared-components.patch
>    hugetlb-split-alloc_huge_page-into-private-and-shared-components-checkpatch-fixes.patch
>    hugetlb-fix-quota-management-for-private-mappings.patch
>    hugetlb-debit-quota-in-alloc_huge_page.patch
>    hugetlb-allow-bulk-updating-in-hugetlb__quota.patch
>    hugetlb-enforce-quotas-during-reservation-for-shared-mappings.patch
> 
> 2. i_blocks accounting
>    hugetlb-fix-i_blocks-accounting.patch
> 
> 3. follow_hugetlb_page (this is a rather nasty bug, I'm glad we
> haven't hit it in real world.  Or maybe Adam did, and hence the
> patch?).

We're starting to see this with the infiniband driver.  They have a
workaround (to touch each hugepage in userspace before handing it to the
driver), but the sooner it gets fixed upstream, the better obviously.

>    hugetlb-follow_hugetlb_page-for-write-access.patch
> 
> 4. others (these are really simple single line low risk patches, why not?)
>    hugetlb-allow-sticky-directory-mount-option.patch
>    mm-hugetlbc-make-a-function-static.patch
> 
> oh, there are more bugs in hugetlb: sys_mincore isn't working on
> hugetlb range.  I guess that can wait for 2.6.25.
> 
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
