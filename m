Date: Mon, 9 Jul 2007 19:30:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: zone movable patches comments
Message-Id: <20070709193033.2feea420.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4691E8D1.4030507@yahoo.com.au>
References: <4691E8D1.4030507@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 09 Jul 2007 17:50:41 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> A few comments -- can it be made configurable? I guess there is not
> much overhead if the zone is not populated, but there has been a fair
> bit of work towards taking out unneeded zones.
> 
Hi, following is a patch for configurable zone, which I used in old days.

- http://marc.info/?l=linux-mm&m=117315623423467&w=2

Will this kind of patch be help ?

> Also, I don't really like the name kernelcore= to specify mem-sizeof
> movable zone. Could it be renamed and stated in the positive, like
> movable_mem= or reserve_movable_mem=? And can that option be written
> up in Documentation?
> 
As far as I remember, before Mel's work, I named "kernelcore=" ops
because "max_dma=", "mem=", ....options are used for specifing the amount of
memory from lower address......
But I have no strong opinion.

> What is the status of these patches? Are they working and pretty well
> ready to be merged for 2.6.23?
> 
At least, works well in our (ia64/NUMA) environment.

Memo: My thinking after OLS 
  ZONE_MOVABLE is necessary for making guarantee to allocate only movable memory
  from some range of physical memory. It is useful but I know people doesn't like it. 
  As an another option, I'm now consdering to specify memory range as "for hotremove"
  by page-type not by zone. This may enable us to avoid adding new zone.
  But I have no concrete idea now and will take some amount of time.

  For NUMA node-hotplug, I think that I have to add another boot ops.
  (For example, boot option for hot-add *removable nodes* after boot.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
