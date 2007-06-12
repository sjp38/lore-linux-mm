Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C3IQ0J003262
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 23:18:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C3HL0N556648
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 23:17:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C3HLfG017184
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 23:17:21 -0400
Date: Mon, 11 Jun 2007 20:17:18 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612031718.GP3798@us.ibm.com>
References: <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com> <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com> <20070612023421.GL3798@us.ibm.com> <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [19:55:21 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > nid is static to alloc_fresh_huge_page().
> 
> Ahh did not see that. Can you not call simply into interleave() from 
> mempolicy.c? It will get you the counter that you need.

You just told me that mempolicy.c is built conditionally on NUMA.
alloc_fresh_huge_page() is not, it only depeonds on CONFIG_HUGETLB_PAGE!

The only interleave functions I see in mempolicy.c are:

interleave_nodes(), which takes a mempolicy, which I don't have in
hugetlb.c

interleave_nid(), which also takes a mempolicy

I guess I could try and use huge_zonelist(), but I don't see the point?

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
