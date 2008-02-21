Date: Thu, 21 Feb 2008 15:35:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080221153536.09c28f44.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080221.114929.42336527.taka@valinux.co.jp>
References: <47BBC15E.5070405@linux.vnet.ibm.com>
	<20080220.185821.61784723.taka@valinux.co.jp>
	<47BC10A8.4020508@linux.vnet.ibm.com>
	<20080221.114929.42336527.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2008 11:49:29 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> > We thought of this as well. We dropped it, because we need to track only user
> > pages at the moment. Doing it for all pages means having the overhead for each
> > page on the system.
> 
> Let me clarify that the overhead you said is you'll waste some memory
> whose pages are assigned for the kernel internal use, right?
> If so, it wouldn't be a big problem since most of the pages are assigned to
> process anonymous memory or to the page cache as Paul said.
> 
My idea is..
(1) It will be big waste of memory to pre-allocate all page_cgroup struct at
    boot.  Because following two will not need it.
    (1) kernel memory
    (2) HugeTLB memory
Mainly because of (2), I don't like pre-allocation.

But we'll be able to archive  pfn <-> page_cgroup relationship using
on-demand memmap style.
(Someone mentioned about using radix-tree in other thread.)

Balbir-san, I'd like to do some work aroung this becasue I've experience
sparsemem and memory hotplug developments.

Or have you already started ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
