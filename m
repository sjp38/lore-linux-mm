Date: Wed, 20 Aug 2008 20:33:30 +0900 (JST)
Message-Id: <20080820.203330.58805720.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH -mm 0/7] memcg: lockless page_cgroup v1
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, ryov@valinux.co.jp, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> Hi, this is a patch set for lockless page_cgroup.
> 
> dropped patches related to mem+swap controller for easy review.
> (I'm rewriting it, too.)
> 
> Changes from current -mm is.
>   - page_cgroup->flags operations is set to be atomic.
>   - lock_page_cgroup() is removed.
>   - page->page_cgroup is changed from unsigned long to struct page_cgroup*
>   - page_cgroup is freed by RCU.
>   - For avoiding race, charge/uncharge against mm/memory.c::insert_page() is
>     omitted. This is ususally used for mapping device's page. (I think...)
> 
> In my quick test, perfomance is improved a little. But the benefit of this
> patch is to allow access page_cgroup without lock. I think this is good 
> for Yamamoto's Dirty page tracking for memcg.
> For I/O tracking people, I added a header file for allowing access to
> page_cgroup from out of memcontrol.c

Thanks, Kame.
It is a good news that the page tracking framework is open.
I think I can send some feedback to you to make it more generic.

> The base kernel is recent mmtom. Any comments are welcome.
> This is still under test. I have to do long-run test before removing "RFC".
> 

Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
