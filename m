Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DKTOHc030873
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 16:29:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DKTOYS557542
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 16:29:24 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DKTN1M018226
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 16:29:23 -0400
Date: Wed, 13 Jun 2007 13:29:21 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v4][RFC] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070613202921.GS3798@us.ibm.com>
References: <20070612050910.GU3798@us.ibm.com> <20070612051512.GC11773@holomorphy.com> <20070612174503.GB3798@us.ibm.com> <20070612191347.GE11781@holomorphy.com> <20070613000446.GL3798@us.ibm.com> <20070613152649.GN3798@us.ibm.com> <20070613152847.GO3798@us.ibm.com> <1181759027.6148.77.camel@localhost> <20070613191908.GR3798@us.ibm.com> <1181765111.6148.98.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181765111.6148.98.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, William Lee Irwin III <wli@holomorphy.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.06.2007 [16:05:10 -0400], Lee Schermerhorn wrote:
> On Wed, 2007-06-13 at 12:19 -0700, Nishanth Aravamudan wrote:
> > On 13.06.2007 [14:23:47 -0400], Lee Schermerhorn wrote:
> > > On Wed, 2007-06-13 at 08:28 -0700, Nishanth Aravamudan wrote:
> > > <snip>
> > > > 
> > > > commit 05a7edb8c909c674cdefb0323348825cf3e2d1d0
> > > > Author: Nishanth Aravamudan <nacc@us.ibm.com>
> > > > Date:   Thu Jun 7 08:54:48 2007 -0700
> > > > 
> > > > hugetlb: add per-node nr_hugepages sysfs attribute
> > > > 
> > > > Allow specifying the number of hugepages to allocate on a particular
> > > > node. Our current global sysctl will try its best to put hugepages
> > > > equally on each node, but htat may not always be desired. This allows
> > > > the admin to control the layout of hugepage allocation at a finer level
> > > > (while not breaking the existing interface). Add callbacks in the sysfs
> > > > node registration and unregistration functions into hugetlb to add the
> > > > nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.
> > > > 
> > > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > > > Cc: William Lee Irwin III <wli@holomorphy.com>
> > > > Cc: Christoph Lameter <clameter@sgi.com>
> > > > Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > > Cc: Anton Blanchard <anton@sambar.org>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > 
> > > > ---
> > > > Do the dummy function definitions need to be (void)0?
> > > > 
> > > 
> > > <snip>
> 
> I tested hugepage allocation on my HP rx8620 platform [16 cpu ia64,
> 32GB in 4 "real" nodes and one pseudo-node containing only DMA
> memory].  As expected, I don't get a balanced distribution across the
> real nodes.  Here's what I see:

Hrm, not good.

Can you try without any of my add-on patches, but just the original set
from Christoph?

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
