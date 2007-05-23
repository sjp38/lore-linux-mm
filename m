Subject: Re: [RFC][PATCH 2/3] hugetlb: numafy several functions
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070523175142.GB9301@us.ibm.com>
References: <20070516233053.GN20535@us.ibm.com>
	 <20070516233155.GO20535@us.ibm.com>  <20070523175142.GB9301@us.ibm.com>
Content-Type: text/plain
Date: Wed, 23 May 2007 15:16:07 -0400
Message-Id: <1179947768.5537.37.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, anton@samba.org, clameter@sgi.com, akpm@linux-foundation.org, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-23 at 10:51 -0700, Nishanth Aravamudan wrote:
> On 16.05.2007 [16:31:55 -0700], Nishanth Aravamudan wrote:
> > Add node-parameterized helpers for dequeue_huge_page,
> > alloc_fresh_huge_page and try_to_free_low. Also have
> > update_and_free_page() take a nid parameter. This is necessary to add a
> > per-node sysfs attribute to specify the number of hugepages on that
> > node.
> 
> I saw that 1/3 was picked up by Andrew, but have not got any responses
> to the other two (I know Adam is out of town...).

Nish:  I haven't had a chance to test these patches.  Other alligators
in the swamp right now.

> 
> Thoughts, comments? Bad idea, good idea?
> 
> I found it pretty handy to specify the exact layout of hugepages on each
> node.

Could be useful for system with unequal memory per node, or where you
know you want more huge pages on a given node.  I recall that Tru64 Unix
used to support something similar:  most vm tunables that involved sizes
or percentages of memory, such as page cache limits, locked memory
limits, reserved huge pages, ..., could be specified as a single value
that was distributed across nodes [backwards compatibility] or as list
of per node values.  However, I don't recall if marketing/customers
asked for this or if it was a case of gratuitous design excess ;-).

I see that we'll need to reconcile the modified alloc_fresh_huge_page
with the patch to skip unpopulated nodes when/if they collide in -mm.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
