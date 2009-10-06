Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD9F6B005A
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:02:22 -0400 (EDT)
Date: Tue, 6 Oct 2009 18:02:16 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/11] hugetlb: V9 numa control of persistent huge pages alloc/free
Message-ID: <20091006160216.GU1656@one.firstfloor.org>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091006031739.22576.5248.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 05, 2009 at 11:17:39PM -0400, Lee Schermerhorn wrote:
> PATCH 0/11 hugetlb: numa control of persistent huge pages alloc/free
> 
> Against:  2.6.31-mmotm-090925-1435 plus David Rientjes'
> "nodemask: make NODEMASK_ALLOC more general" patch applied
> 
> This is V9 of a series of patches to provide control over the location
> of the allocation and freeing of persistent huge pages on a NUMA
> platform.   Please consider for merging into mmotm.

FWIW I reviewed the series briefly and it seems good to me.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
