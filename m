Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A91C76B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 19:37:48 -0400 (EDT)
Date: Thu, 10 Sep 2009 16:36:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] hugetlb:  introduce alloc_nodemask_of_node
Message-Id: <20090910163641.9ebaa601.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.1.00.0909101614060.25078@chino.kir.corp.google.com>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
	<20090909163146.12963.79545.sendpatchset@localhost.localdomain>
	<20090910160541.9f902126.akpm@linux-foundation.org>
	<alpine.DEB.1.00.0909101614060.25078@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: lee.schermerhorn@hp.com, linux-mm@kvack.org, linux-numa@vger.kernel.org, mel@csn.ul.ie, randy.dunlap@oracle.com, nacc@us.ibm.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 Sep 2009 16:17:22 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 10 Sep 2009, Andrew Morton wrote:
> 
> > alloc_nodemask_of_node() has no callers, so I can think of a good fix
> > for these problems.  If it _did_ have a caller then I might ask "can't
> > we fix this by moving alloc_nodemask_of_node() into the .c file".  But
> > it doesn't so I can't.
> > 
> 
> It gets a caller in patch 5 of the series in set_max_huge_pages().

ooh, there it is.

So alloc_nodemask_of_node() could be moved into mm/hugetlb.c.

> My early criticism of both alloc_nodemask_of_node() and 
> alloc_nodemask_of_mempolicy() was that for small CONFIG_NODES_SHIFT (say, 
> 6 or less, which covers all defconfigs except ia64), it is perfectly 
> reasonable to allocate 64 bytes on the stack in the caller.

Spose so.  But this stuff is only called when userspace reconfigures
via sysfs, so it'll be low bandwidth (one sincerely hopes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
