Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 346E26B004D
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:56:57 -0400 (EDT)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n7PJug9s001992
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 12:57:01 -0700
Received: from pxi39 (pxi39.prod.google.com [10.243.27.39])
	by spaceape14.eur.corp.google.com with ESMTP id n7P8Abcx019730
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 01:12:33 -0700
Received: by pxi39 with SMTP id 39so5720824pxi.8
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 01:10:37 -0700 (PDT)
Date: Tue, 25 Aug 2009 01:10:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] hugetlb:  rework hstate_next_node_* functions
In-Reply-To: <20090824192544.10317.6291.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.0908250110090.23660@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192544.10317.6291.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 24 Aug 2009, Lee Schermerhorn wrote:

> [PATCH 1/5] hugetlb:  rework hstate_next_node* functions
> 
> Against: 2.6.31-rc6-mmotm-090820-1918
> 
> V2:
> + cleaned up comments, removed some deemed unnecessary,
>   add some suggested by review
> + removed check for !current in huge_mpol_nodes_allowed().
> + added 'current->comm' to warning message in huge_mpol_nodes_allowed().
> + added VM_BUG_ON() assertion in hugetlb.c next_node_allowed() to
>   catch out of range node id.
> + add examples to patch description
> 
> V3:
> + factored this "cleanup" patch out of V2 patch 2/3
> + moved ahead of patch to add nodes_allowed mask to alloc funcs
>   as this patch is somewhat independent from using task mempolicy
>   to control huge page allocation and freeing.
> 
> Modify the hstate_next_node* functions to allow them to be called to
> obtain the "start_nid".  Then, whereas prior to this patch we
> unconditionally called hstate_next_node_to_{alloc|free}(), whether
> or not we successfully allocated/freed a huge page on the node,
> now we only call these functions on failure to alloc/free to advance
> to next allowed node.
> 
> Factor out the next_node_allowed() function to handle wrap at end
> of node_online_map.  In this version, the allowed nodes include all 
> of the online nodes.
> 
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
