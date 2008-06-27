From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <11849640.1214569478380.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 Jun 2008 21:24:38 +0900 (JST)
Subject: Re: Re: [-mm][PATCH 8/10] fix shmem page migration incorrectness on memcgroup
In-Reply-To: <20080627182952.f8d2b0c3.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080627182952.f8d2b0c3.nishimura@mxp.nes.nec.co.jp>
 <20080625190750.D864.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<28c262360806262208i6791d67at446f7323ded16206@mail.gmail.com>
	<20080627142950.7A83.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<28c262360806270057w2b2d3e56ob4dde9aacf42327b@mail.gmail.com>
	<20080627175201.cbe86a06.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, MinChan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>> But situation is a bit complicated.
>> - shmem's page is charged as file-cache.
>> - shmem's swap cache is still charged by mem_cgroup_cache_charge() because
>>   it's implicitly (to memcg) converted to swap cache. 
>> - anon's swap cache is charged by mem_cgroup_uncharge_cache_page()
>> 
>I'm sorry if I misunderstand something.
>
>I think anon's swap cache is:
>
>- charged by nowhere as "cache".
yes.
>  If anon pages are also on swap cache, charges for them remain charged
>  even when mem_cgroup_uncharge_page() is called, because it checks PG_swapca
che.
>  So, as a result, anon's swap cache is charged.
yes.

>- uncharged by memcgroup_uncharge_page() in __delete_from_swap_cache()
>  after clearing PG_swapcache.
>
>right?
>
You're right. Sorry for confusion.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
