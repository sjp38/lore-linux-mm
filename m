Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m41KPNb0001475
	for <linux-mm@kvack.org>; Thu, 1 May 2008 16:25:23 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m41KPMvs192660
	for <linux-mm@kvack.org>; Thu, 1 May 2008 14:25:22 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m41KPLpL006999
	for <linux-mm@kvack.org>; Thu, 1 May 2008 14:25:22 -0600
Date: Thu, 1 May 2008 13:25:20 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
Message-ID: <20080501202520.GA12354@us.ibm.com>
References: <20080423015429.834926000@nick.local0.net> <20080424235431.GB4741@us.ibm.com> <20080424235829.GC4741@us.ibm.com> <481183FC.9060408@firstfloor.org> <20080425165424.GA9680@us.ibm.com> <Pine.LNX.4.64.0804251210530.5971@schroedinger.engr.sgi.com> <20080425192942.GB14623@us.ibm.com> <Pine.LNX.4.64.0804301215220.27955@schroedinger.engr.sgi.com> <20080430204428.GC6903@us.ibm.com> <Pine.LNX.4.64.0805011222350.8738@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805011222350.8738@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 01.05.2008 [12:23:04 -0700], Christoph Lameter wrote:
> On Wed, 30 Apr 2008, Nishanth Aravamudan wrote:
> 
> > Sure, my point was that we already have the nid in the caller (because
> > we specify it along with GFP_THISNODE). So if we pass that nid down into
> > this new function, we shoulnd't need to do the page_to_nid() call,
> > right?
> 
> Right. But its safer the to page_to_nid() there. In case we do an alloc 
> without __GFP_THISNODE in the future.

In this caller, we will require __GFP_THISNODE for the foreseeable
future. Anything that changes that will be more invasive.

The other callsite can pass the page_to_nid() result as the third
argument.

I'm pretty sure when I first created alloc_huge_page_node(), you argued
for me *not* using page_to_nid() on the returned page because we expect
__GFP_THISNODE to do the right thing.

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
