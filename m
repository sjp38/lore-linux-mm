Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l77N21so032031
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 19:02:01 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l77N21qe167252
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 17:02:01 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l77N20Y7030415
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 17:02:01 -0600
Date: Tue, 7 Aug 2007 16:02:00 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 1/2][UPDATED] hugetlb: search harder for memory in alloc_fresh_huge_page()
Message-ID: <20070807230200.GC15714@us.ibm.com>
References: <20070807171432.GY15714@us.ibm.com> <1186517722.5067.31.camel@localhost> <20070807221240.GB15714@us.ibm.com> <Pine.LNX.4.64.0708071553440.4438@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708071553440.4438@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.08.2007 [15:54:36 -0700], Christoph Lameter wrote:
> On Tue, 7 Aug 2007, Nishanth Aravamudan wrote:
> 
> > > 
> > > Not that I don't trust __GFP_THISNODE, but may I suggest a
> > > "VM_BUG_ON(page_to_nid(page) != nid)" -- up above the spin_lock(), of
> > > course.  Better yet, add the assertion and drop this one line change?
> 
> Dont do this change.

Which change? Using nid without a VM_BUG_ON (as in the original patch)
or adding a VM_BUG_ON and using page_to_nid()?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
