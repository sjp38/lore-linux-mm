Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4PLAAk0018860
	for <linux-mm@kvack.org>; Fri, 25 May 2007 17:10:10 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4PLAAZu244252
	for <linux-mm@kvack.org>; Fri, 25 May 2007 15:10:10 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4PLAAJ3001166
	for <linux-mm@kvack.org>; Fri, 25 May 2007 15:10:10 -0600
Date: Fri, 25 May 2007 14:10:09 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/3] hugetlb: numafy several functions
Message-ID: <20070525211009.GE31717@us.ibm.com>
References: <20070516233053.GN20535@us.ibm.com> <20070516233155.GO20535@us.ibm.com> <20070523175142.GB9301@us.ibm.com> <1179947768.5537.37.camel@localhost> <20070523192951.GE9301@us.ibm.com> <20070525194318.GD31717@us.ibm.com> <1180126559.5730.73.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1180126559.5730.73.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: wli@holomorphy.com, anton@samba.org, clameter@sgi.com, akpm@linux-foundation.org, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.05.2007 [16:55:59 -0400], Lee Schermerhorn wrote:
> On Fri, 2007-05-25 at 12:43 -0700, Nishanth Aravamudan wrote:
> > Andrew,
> > 
> <snip>
> > > 
> > > Yeah, if folks like the interface and are satisfied with it working,
> > > I'll rebase onto -mm for Andrew's sanity.
> > 
> > Would you like me to rebase onto 2.6.22-rc2-mm1? I think this is a very
> > useful feature for NUMA systems that may have an unequal distribution of
> > memory and don't like the hugepage allocations provided by the global
> > sysctl.
> > 
> > If I recall right, the collisions with Lee's hugetlb.c changes were
> > pretty small, so it shouldn't be any trouble at all.
> 
> Nish:
> 
> Unless I missed your post, I think Andrew is waiting to hear from you
> on the results of your testing of the 22-rc2 based v4 patch before
> merging the huge page allocation fix.

Err, right.

Preliminary results:

x86 2-node success
x86_64 4-node success

ppc64 4-node fails with mainline, still investigating
x86 1-node fails with mainline, believe it is machine setup error,
	trying with another one

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
