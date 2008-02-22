Date: Fri, 22 Feb 2008 12:31:00 +0900 (JST)
Message-Id: <20080222.123100.54101482.taka@valinux.co.jp>
Subject: [RFC] Block I/O Cgroup
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080221184450.c30f24d6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080221182156.63e5fc25.kamezawa.hiroyu@jp.fujitsu.com>
	<47BD4438.4030203@linux.vnet.ibm.com>
	<20080221184450.c30f24d6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

It'll be great if you make the feature --- page to mem_cgroup mapping
mechanism --- generic, which will make it easy to implement a Block I/O
controller. With this feature, you can easily determine the origin cgroup
from the page which is going to start I/O.

 mem_cgroup        block_io_cgroup
     ^                 ^       |
     |                 |       |
     |                 |       |
     +------->page<----+       V
                ^          io_context
                |            ^
                |            |
               bio ----------+

Every page should be associated with the proper block_io_cgroup when
the need arises. The simplest way is to make it at the same point as
mem_cgroups does. It's also possible to do this when the pages get dirtied.

> > > But yes. I'm afraid of lock contention very much. I'll find another lock-less way
> > > if necessary. One idea is map each area like sparsemem_vmemmap for 64bit systems.
> > > Now, I'm convinced that it will be complicated ;)
> > > 
> > 
> > The radix tree base is lockless (it uses RCU), so we might have a partial
> > solution to the locking problem. But it's unchartered territory, so no one knows.
> > 
> > > I'd like to start from easy way and see performance.
> > > 
> > 
> > Sure, please keep me in the loop as well.
> > 
> Okay, I'll do my best.
> 
> Thanks,
> -Kame


Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
