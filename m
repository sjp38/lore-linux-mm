Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C3KvDi014438
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 23:20:57 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C3KvLv270822
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:20:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C3KvSi017076
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:20:57 -0600
Date: Mon, 11 Jun 2007 20:20:55 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070612032055.GQ3798@us.ibm.com>
References: <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com> <20070611234155.GG14458@us.ibm.com> <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com> <20070612000705.GH14458@us.ibm.com> <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com> <20070612020257.GF3798@us.ibm.com> <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com> <20070612023209.GJ3798@us.ibm.com> <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [19:54:13 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > On 11.06.2007 [19:20:58 -0700], Christoph Lameter wrote:
> > > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > > 
> > > > [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
> > > 
> > > There is no point in compiling the interleave logic for !NUMA.
> > > There needs to be some sort of !NUMA fallback in hugetlb. It would
> > > be better to call a interleave function in mempolicy.c that
> > > provides an appropriate shim for !NUMA.
> > 
> > Hrm, if !NUMA, is the nid of the only node guaranteed to be 0? If so, I
> > can just
> 
> Yes.
> 
> > Make alloc_fresh_huge_page() and other generic variants call into
> > the _node() versions with nid=0, if !NUMA.
> > 
> > Would that be ok?
> 
> I am not sure what you are up to. Just make sure that the changes are
> minimal. Look in the source code for other examples on how !NUMA
> situations were handled.

I swear I'm trying to make the code do the right thing, and understand
the NUMA intricacies better. Sorry for the flood of e-mails and such. I
asked about specific other cases because they are used in !NUMA
situations too and I wasn't sure why node_populated_map should be
different.

But ok, I will rely on the source to be correct and make my changelog
indicate where I got the ideas from.

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
