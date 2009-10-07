Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 501786B006A
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 00:12:12 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n974C7M2003487
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 21:12:08 -0700
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by wpaz13.hot.corp.google.com with ESMTP id n974BLOj021972
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 21:12:05 -0700
Received: by pzk11 with SMTP id 11so2929950pzk.14
        for <linux-mm@kvack.org>; Tue, 06 Oct 2009 21:12:05 -0700 (PDT)
Date: Tue, 6 Oct 2009 21:12:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 10/11] hugetlb:  handle memory hot-plug events
In-Reply-To: <20091006031838.22576.61261.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910062111490.3099@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031838.22576.61261.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Lee Schermerhorn wrote:

> [PATCH 10/11] hugetlb:  per node attributes -- handle memory hot plug
> 
> Against:  2.6.31-mmotm-090925-1435
> 
> Register per node hstate attributes only for nodes with memory.
> 
> With Memory Hotplug, memory can be added to a memoryless node and
> a node with memory can become memoryless.  Therefore, add a memory
> on/off-line notifier callback to [un]register a node's attributes
> on transition to/from memoryless state.
> 
> N.B.,  Only tested build, boot, libhugetlbfs regression.
>        i.e., no memory hotplug testing.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
