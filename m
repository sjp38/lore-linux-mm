Date: Thu, 21 Feb 2008 18:07:45 +0900 (JST)
Message-Id: <20080221.180745.74279466.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080221153536.09c28f44.kamezawa.hiroyu@jp.fujitsu.com>
References: <47BC10A8.4020508@linux.vnet.ibm.com>
	<20080221.114929.42336527.taka@valinux.co.jp>
	<20080221153536.09c28f44.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

> > > We thought of this as well. We dropped it, because we need to track only user
> > > pages at the moment. Doing it for all pages means having the overhead for each
> > > page on the system.
> > 
> > Let me clarify that the overhead you said is you'll waste some memory
> > whose pages are assigned for the kernel internal use, right?
> > If so, it wouldn't be a big problem since most of the pages are assigned to
> > process anonymous memory or to the page cache as Paul said.
> > 
> My idea is..
> (1) It will be big waste of memory to pre-allocate all page_cgroup struct at
>     boot.  Because following two will not need it.
>     (1) kernel memory
>     (2) HugeTLB memory
> Mainly because of (2), I don't like pre-allocation.

I thought kernel memory wasn't big deal but I didn't think about HugeTLB memory.

> But we'll be able to archive  pfn <-> page_cgroup relationship using
> on-demand memmap style.
> (Someone mentioned about using radix-tree in other thread.)

My concern is this approach seems to require some spinlocks to protect the
radix-tree. If you really don't want to allocate page_cgroups for HugeTLB
memory, what do you think if you should turn on the memory controller after
allocating HugeTlb pages?

> Balbir-san, I'd like to do some work aroung this becasue I've experience
> sparsemem and memory hotplug developments.
> 
> Or have you already started ?

Not yet. So you can go ahead.

> Thanks,
> -Kame

Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
