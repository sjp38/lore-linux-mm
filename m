Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E04B66B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:01:43 -0400 (EDT)
Date: Tue, 6 Oct 2009 18:01:39 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 11/11] hugetlb:  offload per node attribute registrations
Message-ID: <20091006160139.GT1656@one.firstfloor.org>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031924.22576.35018.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091006031924.22576.35018.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 05, 2009 at 11:19:24PM -0400, Lee Schermerhorn wrote:
> [PATCH 11/11] hugetlb:  offload [un]registration of sysfs attr to worker thread
> 
> Against:  2.6.31-mmotm-090925-1435
> 
> New in V6
> 
> V7:  + remove redundant check for memory{ful|less} node from 
>        node_hugetlb_work().  Rely on [added] return from
>        hugetlb_register_node() to differentiate between transitions
>        to/from memoryless state.
> 
> This patch offloads the registration and unregistration of per node
> hstate sysfs attributes to a worker thread rather than attempt the
> allocation/attachment or detachment/freeing of the attributes in 
> the context of the memory hotplug handler.

Why this change? The hotplug handler should be allowed to sleep, shouldn't it?

> N.B.,  Only tested build, boot, libhugetlbfs regression.
>        i.e., no memory hotplug testing.

Yes, you have to because I know for a fact it's broken (outside your code) :)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
