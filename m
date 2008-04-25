Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PGsWMD009935
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 12:54:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PGsRO1188040
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 10:54:32 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PGsQPp018608
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 10:54:26 -0600
Date: Fri, 25 Apr 2008 09:54:24 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
Message-ID: <20080425165424.GA9680@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015429.834926000@nick.local0.net> <20080424235431.GB4741@us.ibm.com> <20080424235829.GC4741@us.ibm.com> <481183FC.9060408@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <481183FC.9060408@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On 25.04.2008 [09:10:52 +0200], Andi Kleen wrote:
> Nishanth Aravamudan wrote:
> > On 24.04.2008 [16:54:31 -0700], Nishanth Aravamudan wrote:
> >> On 23.04.2008 [11:53:04 +1000], npiggin@suse.de wrote:
> >>> Needed to avoid code duplication in follow up patches.
> >>>
> >>> This happens to fix a minor bug. When alloc_bootmem_node returns
> >>> a fallback node on a different node than passed the old code
> >>> would have put it into the free lists of the wrong node.
> >>> Now it would end up in the freelist of the correct node.
> >> This is rather frustrating. The whole point of having the __GFP_THISNODE
> >> flag is to indicate off-node allocations are *not* supported from the
> >> caller... This was all worked on quite heavily a while back.
> 
> Perhaps it was, but the result in hugetlb.c was not correct.

Huh? There is a case in current code (current hugepage sizes) that
allows __GFP_THISNODE to go off-node?

> > Oh I see. This patch refers to a bug that only is introduced by patch
> > 12/18...perhaps *that* patch should add the nid calculation in the
> > helper, if it is truly needed.
> 
> No, the bug is already there even without the bootmem patch.

Where does alloc_pages_node go off-node? It is a bug in the core VM if
it does, as we decided __GFP_THISNODE semantics with a nid specified
indicates *no* fallback should occur.

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
