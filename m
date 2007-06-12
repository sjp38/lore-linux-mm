Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l5C2RhmM014984
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:27:43 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C2WClI107212
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:32:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C2WB4t014887
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:32:12 -0600
Date: Mon, 11 Jun 2007 19:32:09 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070612023209.GJ3798@us.ibm.com>
References: <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com> <20070611234155.GG14458@us.ibm.com> <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com> <20070612000705.GH14458@us.ibm.com> <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com> <20070612020257.GF3798@us.ibm.com> <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [19:20:58 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
> 
> There is no point in compiling the interleave logic for !NUMA. There
> needs to be some sort of !NUMA fallback in hugetlb. It would be better
> to call a interleave function in mempolicy.c that provides an
> appropriate shim for !NUMA.

Hrm, if !NUMA, is the nid of the only node guaranteed to be 0? If so, I
can just

Make alloc_fresh_huge_page() and other generic variants call into the
_node() versions with nid=0, if !NUMA.

Would that be ok?

I'm not sure what kind of interleave function you're thinking of that
could be in mempolicy.c? Note, this code used node_online_map before,
which was also overkill in !NUMA.

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
