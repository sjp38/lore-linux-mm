Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m41KwUpI023666
	for <linux-mm@kvack.org>; Thu, 1 May 2008 16:58:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m41L1IVC212084
	for <linux-mm@kvack.org>; Thu, 1 May 2008 15:01:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4231IkZ017178
	for <linux-mm@kvack.org>; Thu, 1 May 2008 21:01:18 -0600
Date: Thu, 1 May 2008 14:01:16 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
Message-ID: <20080501210116.GB12354@us.ibm.com>
References: <20080424235829.GC4741@us.ibm.com> <481183FC.9060408@firstfloor.org> <20080425165424.GA9680@us.ibm.com> <Pine.LNX.4.64.0804251210530.5971@schroedinger.engr.sgi.com> <20080425192942.GB14623@us.ibm.com> <Pine.LNX.4.64.0804301215220.27955@schroedinger.engr.sgi.com> <20080430204428.GC6903@us.ibm.com> <Pine.LNX.4.64.0805011222350.8738@schroedinger.engr.sgi.com> <20080501202520.GA12354@us.ibm.com> <Pine.LNX.4.64.0805011333430.9486@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805011333430.9486@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 01.05.2008 [13:34:23 -0700], Christoph Lameter wrote:
> On Thu, 1 May 2008, Nishanth Aravamudan wrote:
> 
> > I'm pretty sure when I first created alloc_huge_page_node(), you argued
> > for me *not* using page_to_nid() on the returned page because we expect
> > __GFP_THISNODE to do the right thing.
> 
> I vaguely remember that the issue at that point was that you were trying 
> to compensate for __GFP_THISNODE brokenness?

That's a good point -- it was at the time. My point is again here, this
particular callpath *is* using __GPF_THISNODE -- and always will as it's
a node-specific function call. Other callpaths may not, yes, but they
are passing the page in, which means they can call page_to_nid(). Just
seems to calculate a nid we already have.

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
