Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AADAE6B004F
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 18:38:51 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n7EMcn1Y012640
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 23:38:50 +0100
Received: from pxi36 (pxi36.prod.google.com [10.243.27.36])
	by wpaz21.hot.corp.google.com with ESMTP id n7EMcSi0013343
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 15:38:47 -0700
Received: by pxi36 with SMTP id 36so440884pxi.7
        for <linux-mm@kvack.org>; Fri, 14 Aug 2009 15:38:45 -0700 (PDT)
Date: Fri, 14 Aug 2009 15:38:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
In-Reply-To: <1249067452.4674.235.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.2.00.0908141532510.23204@chino.kir.corp.google.com>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain> <20090729181205.23716.25002.sendpatchset@localhost.localdomain> <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com> <20090731103632.GB28766@csn.ul.ie>
 <1249067452.4674.235.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 31 Jul 2009, Lee Schermerhorn wrote:

> PATCH/RFC 5/4 hugetlb:  register per node hugepages attributes
> 
> Against: 2.6.31-rc4-mmotm-090730-0510
> and the hugetlb rework and mempolicy-based nodes_allowed
> series
> 

Andrew, Lee, what's the status of this patchset?  I don't see it, or the 
mempolicy support version, in mmotm-2009-08-12-13-55.

I think there are use cases for both the per-node hstate attributes and 
the mempolicy restricted hugepage allocation support and both features can 
co-exist in the kernel.

My particular interest is in the per-node hstate attributes because it 
allows job schedulers to preallocate hugepages in nodes attached to a 
cpuset with ease and allows node-targeted hugepage freeing for balanced 
allocations, which is a prerequisite for effective interleave 
optimizations.

I'd encourage the addition of the per-node hstate attributes to mmotm.  
Thanks Lee for implementing this feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
