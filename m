Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l781X1YS001085
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 21:33:01 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l781X0pY269500
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 19:33:01 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l781X00A002125
	for <linux-mm@kvack.org>; Tue, 7 Aug 2007 19:33:00 -0600
Date: Tue, 7 Aug 2007 18:32:56 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 1/2][UPDATED] hugetlb: search harder for memory in alloc_fresh_huge_page()
Message-ID: <20070808013256.GE15714@us.ibm.com>
References: <20070807171432.GY15714@us.ibm.com> <1186517722.5067.31.camel@localhost> <20070807221240.GB15714@us.ibm.com> <Pine.LNX.4.64.0708071553440.4438@schroedinger.engr.sgi.com> <20070807230200.GC15714@us.ibm.com> <Pine.LNX.4.64.0708071714060.5001@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708071714060.5001@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.08.2007 [17:14:31 -0700], Christoph Lameter wrote:
> On Tue, 7 Aug 2007, Nishanth Aravamudan wrote:
> 
> > Which change? Using nid without a VM_BUG_ON (as in the original patch)
> > or adding a VM_BUG_ON and using page_to_nid()?
> 
> Adding VM_BUG_ON. If page_alloc does not work then something basic is 
> broken.

I agree. So perhaps there needs to be a VM_BUG_ON_ONCE() or something
somewhere in the core code for the case of a __GFP_THISNODE allocation
going off node?

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
