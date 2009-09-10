Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BB8256B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 19:17:28 -0400 (EDT)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id n8ANHSgg021597
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 00:17:28 +0100
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by spaceape23.eur.corp.google.com with ESMTP id n8ANH6ZA018686
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 16:17:26 -0700
Received: by pzk4 with SMTP id 4so444524pzk.22
        for <linux-mm@kvack.org>; Thu, 10 Sep 2009 16:17:25 -0700 (PDT)
Date: Thu, 10 Sep 2009 16:17:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] hugetlb:  introduce alloc_nodemask_of_node
In-Reply-To: <20090910160541.9f902126.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.00.0909101614060.25078@chino.kir.corp.google.com>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain> <20090909163146.12963.79545.sendpatchset@localhost.localdomain> <20090910160541.9f902126.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, mel@csn.ul.ie, randy.dunlap@oracle.com, nacc@us.ibm.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 Sep 2009, Andrew Morton wrote:

> alloc_nodemask_of_node() has no callers, so I can think of a good fix
> for these problems.  If it _did_ have a caller then I might ask "can't
> we fix this by moving alloc_nodemask_of_node() into the .c file".  But
> it doesn't so I can't.
> 

It gets a caller in patch 5 of the series in set_max_huge_pages().

My early criticism of both alloc_nodemask_of_node() and 
alloc_nodemask_of_mempolicy() was that for small CONFIG_NODES_SHIFT (say, 
6 or less, which covers all defconfigs except ia64), it is perfectly 
reasonable to allocate 64 bytes on the stack in the caller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
