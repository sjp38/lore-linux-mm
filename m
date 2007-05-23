Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4NJTqlJ027111
	for <linux-mm@kvack.org>; Wed, 23 May 2007 15:29:52 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4NJTqBQ557122
	for <linux-mm@kvack.org>; Wed, 23 May 2007 15:29:52 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4NJTpi1003425
	for <linux-mm@kvack.org>; Wed, 23 May 2007 15:29:52 -0400
Date: Wed, 23 May 2007 12:29:51 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/3] hugetlb: numafy several functions
Message-ID: <20070523192951.GE9301@us.ibm.com>
References: <20070516233053.GN20535@us.ibm.com> <20070516233155.GO20535@us.ibm.com> <20070523175142.GB9301@us.ibm.com> <1179947768.5537.37.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1179947768.5537.37.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: wli@holomorphy.com, anton@samba.org, clameter@sgi.com, akpm@linux-foundation.org, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23.05.2007 [15:16:07 -0400], Lee Schermerhorn wrote:
> On Wed, 2007-05-23 at 10:51 -0700, Nishanth Aravamudan wrote:
> > On 16.05.2007 [16:31:55 -0700], Nishanth Aravamudan wrote:
> > > Add node-parameterized helpers for dequeue_huge_page,
> > > alloc_fresh_huge_page and try_to_free_low. Also have
> > > update_and_free_page() take a nid parameter. This is necessary to add a
> > > per-node sysfs attribute to specify the number of hugepages on that
> > > node.
> > 
> > I saw that 1/3 was picked up by Andrew, but have not got any responses
> > to the other two (I know Adam is out of town...).
> 
> Nish:  I haven't had a chance to test these patches.  Other alligators
> in the swamp right now.

No problem.

> > Thoughts, comments? Bad idea, good idea?
> > 
> > I found it pretty handy to specify the exact layout of hugepages on each
> > node.
> 
> Could be useful for system with unequal memory per node, or where you
> know you want more huge pages on a given node.  I recall that Tru64 Unix
> used to support something similar:  most vm tunables that involved sizes
> or percentages of memory, such as page cache limits, locked memory
> limits, reserved huge pages, ..., could be specified as a single value
> that was distributed across nodes [backwards compatibility] or as list
> of per node values.  However, I don't recall if marketing/customers
> asked for this or if it was a case of gratuitous design excess ;-).

Yep, exactly the kind of use cases I was thinking of.

> I see that we'll need to reconcile the modified alloc_fresh_huge_page
> with the patch to skip unpopulated nodes when/if they collide in -mm.

Yeah, if folks like the interface and are satisfied with it working,
I'll rebase onto -mm for Andrew's sanity.

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
