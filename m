Date: Fri, 22 Feb 2008 14:05:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Block I/O Cgroup
Message-Id: <20080222140506.f7e25638.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080222.123100.54101482.taka@valinux.co.jp>
References: <20080221182156.63e5fc25.kamezawa.hiroyu@jp.fujitsu.com>
	<47BD4438.4030203@linux.vnet.ibm.com>
	<20080221184450.c30f24d6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080222.123100.54101482.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2008 12:31:00 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> Hi,
> 
> It'll be great if you make the feature --- page to mem_cgroup mapping
> mechanism --- generic, which will make it easy to implement a Block I/O
> controller. With this feature, you can easily determine the origin cgroup
> from the page which is going to start I/O.
> 
>  mem_cgroup        block_io_cgroup
>      ^                 ^       |
>      |                 |       |
>      |                 |       |
>      +------->page<----+       V
>                 ^          io_context
>                 |            ^
>                 |            |
>                bio ----------+
> 
> Every page should be associated with the proper block_io_cgroup when
> the need arises. The simplest way is to make it at the same point as
> mem_cgroups does. It's also possible to do this when the pages get dirtied.
> 

Just exporiting interface for page_to_page_cgroup() interface will be ok.
But, then, it seems your io controller cannot be used if memory resource
controller is not available.
That's acceptable ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
