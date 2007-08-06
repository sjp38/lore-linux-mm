Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76IFYhM026547
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 14:15:34 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76IFYlh260166
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:15:34 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76IFXkK024362
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:15:34 -0600
Date: Mon, 6 Aug 2007 11:15:32 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/5] hugetlb: numafy several functions
Message-ID: <20070806181532.GR15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com> <20070806163841.GL15714@us.ibm.com> <Pine.LNX.4.64.0708061058380.24256@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708061058380.24256@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 06.08.2007 [10:59:20 -0700], Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:
> 
> > +	page = alloc_pages_node(nid,
> > +			GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
> > +			HUGETLB_PAGE_ORDER);
> 
> GFP_THISNODE disables reclaim. With Mel Gorman's ZONE_MOVABLE you may
> want to enable reclaim here. Use __GFP_THISNODE?

It is GFP_THISNODE currently. That seems like a separate logical change
which I'll have to consider separately.

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
