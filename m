Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C8CAA6B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 16:58:26 -0400 (EDT)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n95KwNDi018155
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 13:58:23 -0700
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by spaceape14.eur.corp.google.com with ESMTP id n95KwDIF016114
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 13:58:20 -0700
Received: by pzk38 with SMTP id 38so3443636pzk.9
        for <linux-mm@kvack.org>; Mon, 05 Oct 2009 13:58:19 -0700 (PDT)
Date: Mon, 5 Oct 2009 13:58:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/10] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <1254741326.4389.16.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0910051354380.10476@chino.kir.corp.google.com>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165832.32248.32725.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910021513090.18180@chino.kir.corp.google.com>
 <1254741326.4389.16.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Lee Schermerhorn wrote:

> > mm/hugetlb.c: In function 'nr_hugepages_store_common':
> > mm/hugetlb.c:1368: error: storage size of '_m' isn't known
> > mm/hugetlb.c:1380: warning: passing argument 1 of 'init_nodemask_of_mempolicy' from incompatible pointer type
> > mm/hugetlb.c:1382: warning: assignment from incompatible pointer type
> > mm/hugetlb.c:1390: warning: passing argument 1 of 'init_nodemask_of_node' from incompatible pointer type
> > mm/hugetlb.c:1392: warning: passing argument 3 of 'set_max_huge_pages' from incompatible pointer type
> > mm/hugetlb.c:1394: warning: comparison of distinct pointer types lacks a cast
> > mm/hugetlb.c:1368: warning: unused variable '_m'
> > mm/hugetlb.c: In function 'hugetlb_sysctl_handler_common':
> > mm/hugetlb.c:1862: error: storage size of '_m' isn't known
> > mm/hugetlb.c:1864: warning: passing argument 1 of 'init_nodemask_of_mempolicy' from incompatible pointer type
> > mm/hugetlb.c:1866: warning: assignment from incompatible pointer type
> > mm/hugetlb.c:1868: warning: passing argument 3 of 'set_max_huge_pages' from incompatible pointer type
> > mm/hugetlb.c:1870: warning: comparison of distinct pointer types lacks a cast
> > mm/hugetlb.c:1862: warning: unused variable '_m'
> 
> 
> ??? This is after your rework of NODEMASK_ALLOC has been applied?  I
> don't see this when I build the mmotm that the patch is based on.  
> 

This was mmotm-09251435 plus this entire patchset.

You may want to check your toolchain if you don't see these errors, this 
particular patch adds NODEMASK_ALLOC(nodemask, nodes_allowed) which would 
expand out to allocating a "struct nodemask" either dynamically or on the 
stack and such an object doesn't exist in the kernel.

> Ah, but your patch didn't exist back then :).
> 
> I guess I'll tack this onto the end of V9 with a note that it depends on
> your patch.  Altho' for bisection builds, I might want to break it into
> separate patches that apply to the mempolicy and per node attributes
> patches, respectively.
> 

Feel free to just fold it into patch 4 so the series builds incrementally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
