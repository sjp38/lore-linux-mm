Date: Thu, 21 Feb 2008 18:21:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080221182156.63e5fc25.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080221.180745.74279466.taka@valinux.co.jp>
References: <47BC10A8.4020508@linux.vnet.ibm.com>
	<20080221.114929.42336527.taka@valinux.co.jp>
	<20080221153536.09c28f44.kamezawa.hiroyu@jp.fujitsu.com>
	<20080221.180745.74279466.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2008 18:07:45 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:
> > But we'll be able to archive  pfn <-> page_cgroup relationship using
> > on-demand memmap style.
> > (Someone mentioned about using radix-tree in other thread.)
> 
> My concern is this approach seems to require some spinlocks to protect the
> radix-tree. 

Unlike file-cache, radix-tree enries are not frequently changed.
Then we have a chance to cache recently used value to per_cpu area for avoiding
radix_tree lock.

But yes. I'm afraid of lock contention very much. I'll find another lock-less way
if necessary. One idea is map each area like sparsemem_vmemmap for 64bit systems.
Now, I'm convinced that it will be complicated ;)

I'd like to start from easy way and see performance.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
