Date: Fri, 22 Feb 2008 14:45:53 +0900 (JST)
Message-Id: <20080222.144553.102788842.taka@valinux.co.jp>
Subject: Re: [RFC] Block I/O Cgroup
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080222140506.f7e25638.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080221184450.c30f24d6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080222.123100.54101482.taka@valinux.co.jp>
	<20080222140506.f7e25638.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

> > It'll be great if you make the feature --- page to mem_cgroup mapping
> > mechanism --- generic, which will make it easy to implement a Block I/O
> > controller. With this feature, you can easily determine the origin cgroup
> > from the page which is going to start I/O.
> > 
> >  mem_cgroup        block_io_cgroup
> >      ^                 ^       |
> >      |                 |       |
> >      |                 |       |
> >      +------->page<----+       V
> >                 ^          io_context
> >                 |            ^
> >                 |            |
> >                bio ----------+
> > 
> > Every page should be associated with the proper block_io_cgroup when
> > the need arises. The simplest way is to make it at the same point as
> > mem_cgroups does. It's also possible to do this when the pages get dirtied.
> > 
> 
> Just exporiting interface for page_to_page_cgroup() interface will be ok.
> But, then, it seems your io controller cannot be used if memory resource
> controller is not available.
> That's acceptable ?

I think you can split the current code into two parts, the generic part and
the mem_cgroup dependant part. It's okay if the generic part is on when
other cgroups such as "block io controller" wants to use it.


Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
