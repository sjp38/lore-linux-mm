Date: Wed, 20 Aug 2008 19:41:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH -mm 0/7] memcg: lockless page_cgroup v1
Message-Id: <20080820194108.e76b20b3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Aug 2008 18:53:06 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

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
> 
> The base kernel is recent mmtom. Any comments are welcome.
> This is still under test. I have to do long-run test before removing "RFC".
> 
Known problem: force_emtpy is broken...so rmdir will struck into nightmare.
It's because of patch 2/7.
will be fixed in the next version.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
