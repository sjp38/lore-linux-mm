Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D8DE96B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:20:40 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n98KKdBF012603
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:20:39 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz13.hot.corp.google.com with ESMTP id n98KKapE013649
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:20:36 -0700
Received: by pzk33 with SMTP id 33so3453441pzk.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2009 13:20:35 -0700 (PDT)
Date: Thu, 8 Oct 2009 13:20:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/12] hugetlb:  factor init_nodemask_of_node
In-Reply-To: <20091008162521.23192.32391.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910081320210.6998@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162521.23192.32391.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Oct 2009, Lee Schermerhorn wrote:

> [PATCH 4/12] hugetlb:  factor init_nodemask_of_node()
> 
> Factor init_nodemask_of_node() out of the nodemask_of_node()
> macro.
> 
> This will be used to populate the huge pages "nodes_allowed"
> nodemask for a single node when basing nodes_allowed on a
> preferred/local mempolicy or when a persistent huge page
> pool page count is modified via a per node sysfs attribute.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Andi Kleen <andi@firstfloor.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
