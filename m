Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m0HCC5fK006701
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 17:42:05 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0HCC4L21142804
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 17:42:04 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m0HCC4cu015120
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 12:12:04 GMT
Date: Thu, 17 Jan 2008 17:42:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] shared page table for hugetlbpage memory causing leak.
Message-ID: <20080117121205.GM11384@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <478E3DFA.9050900@redhat.com> <1200509668.3296.204.camel@localhost.localdomain> <20080117101946.GJ11384@balbir.in.ibm.com> <1200570818.18160.2.camel@dhcp83-56.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1200570818.18160.2.camel@dhcp83-56.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Larry Woodman <lwoodman@redhat.com> [2008-01-17 06:53:38]:

> On Thu, 2008-01-17 at 15:49 +0530, Balbir Singh wrote:
> > * Adam Litke <agl@us.ibm.com> [2008-01-16 12:54:28]:
> > 
> > > Since we know we are dealing with a hugetlb VMA, how about the
> > > following, simpler, _untested_ patch:
> > > 
> > > Signed-off-by: Adam Litke <agl@us.ibm.com>
> > > 
> > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > index 6f97821..75b0e4f 100644
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -644,6 +644,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> > >  		dst_pte = huge_pte_alloc(dst, addr);
> > >  		if (!dst_pte)
> > >  			goto nomem;
> > > +
> > > +		/* If page table is shared do not copy or take references */
> > > +		if (src_pte == dst_pte)
> > > +			continue;
> > > +
> > 
> > Shouldn't you be checking the PTE contents rather than the pointers?
> No, this is chacking for shared page tables not shared pages.

Aah.. I see.

Thanks for clarifying!

-- 
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
