Date: Thu, 06 Mar 2008 19:03:04 +0900 (JST)
Message-Id: <20080306.190304.83917780.taka@valinux.co.jp>
Subject: Re: [Preview] [PATCH] radix tree based page cgroup [0/6]
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080305205137.5c744097.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

Hi,

> Hi, this is the latest version of radix-tree based page cgroup patch.
> 
> I post this now because recent major changes are included in 2.6.25-rc4.
> (I admit I should do more tests on this set.)
> 
> Almost all are rewritten and adjusted to rc4's logic.
> I feel this set is simpler than previous one.
> 
> Patch series is following.
> [1/6] page cgroup definition
> [2/6] patch against charge/uncharge 
> [3/6] patch against move_list
> [4/6] patch against migration
> [5/6] radix tree based page_cgroup
> [6/6] boost by per-cpu cache.
> 
>  * force_empty patch is dropped because it's unnecessary.
>  * vmalloc patch is dropped. we always use kmalloc in this version.
> 
> TODO:
>   - add freeing page_cgroup routine. it seems necessary sometimes.
>     (I have one and will be added to this set in the next post.)

I doubt page_cgroups can be freed effectively since most of the pages
are used and each of them has its corresponding page_cgroup when you
need more free memory.

In this case, right after some page_cgroup freed when the corresponding
pages are released, these pages are reallocated and page_cgroups are
also reallocated and assigned to them. It will only give us meaningless
overhead.

And I think it doesn't make sense to free page_cgroups to make much more
free memory if there are a lot of free memory,

I guess freeing page_cgroup routine will be fine when making hugetlb
pages.

>   - Logic check again.
> 
> Thanks,
> -Kame


Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
