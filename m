Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EACAC6B005D
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 14:39:43 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n83Idhgp004847
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 11:39:43 -0700
Received: from pxi42 (pxi42.prod.google.com [10.243.27.42])
	by zps37.corp.google.com with ESMTP id n83IcSTf023861
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 11:39:41 -0700
Received: by pxi42 with SMTP id 42so125278pxi.20
        for <linux-mm@kvack.org>; Thu, 03 Sep 2009 11:39:41 -0700 (PDT)
Date: Thu, 3 Sep 2009 11:39:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/6] hugetlb:  add nodemask arg to huge page alloc, free
 and surplus adjust fcns
In-Reply-To: <20090828160326.11080.56814.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0909031138010.9055@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160326.11080.56814.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Aug 2009, Lee Schermerhorn wrote:

> [PATCH 2/6] hugetlb:  add nodemask arg to huge page alloc, free and surplus adjust fcns
> 
> Against:  2.6.31-rc7-mmotm-090827-0057
> 
> V3:
> + moved this patch to after the "rework" of hstate_next_node_to_...
>   functions as this patch is more specific to using task mempolicy
>   to control huge page allocation and freeing.
> 
> V5:
> + removed now unneeded 'nextnid' from hstate_next_node_to_{alloc|free}
>   and updated the stale comments.
> 
> In preparation for constraining huge page allocation and freeing by the
> controlling task's numa mempolicy, add a "nodes_allowed" nodemask pointer
> to the allocate, free and surplus adjustment functions.  For now, pass
> NULL to indicate default behavior--i.e., use node_online_map.  A
> subsqeuent patch will derive a non-default mask from the controlling 
> task's numa mempolicy.
> 
> Note that this method of updating the global hstate nr_hugepages under
> the constraint of a nodemask simplifies keeping the global state 
> consistent--especially the number of persistent and surplus pages
> relative to reservations and overcommit limits.  There are undoubtedly
> other ways to do this, but this works for both interfaces:  mempolicy
> and per node attributes.
> 
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Still think the name `this_node_allowed()' is awkward, but I'm glad to see 
hstate_next_node_to_{alloc,free} is clean.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
