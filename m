Date: Mon, 1 Sep 2008 15:59:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080901155930.e45a36c8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48BB8AE3.7070704@linux.vnet.ibm.com>
References: <20080831174756.GA25790@balbir.in.ibm.com>
	<20080901090102.46b75141.kamezawa.hiroyu@jp.fujitsu.com>
	<48BB6160.4070904@linux.vnet.ibm.com>
	<20080901130351.f005d5b6.kamezawa.hiroyu@jp.fujitsu.com>
	<48BB8716.5090805@linux.vnet.ibm.com>
	<20080901152424.d9adfe47.kamezawa.hiroyu@jp.fujitsu.com>
	<48BB8AE3.7070704@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, 01 Sep 2008 11:55:39 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Mon, 01 Sep 2008 11:39:26 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > 
> >>> The development of lockless-page_cgroup is not stalled. I'm just waiting for
> >>> my 8cpu box comes back from maintainance...
> >>> If you want to see, I'll post v3 with brief result on small (2cpu) box.
> >>>
> >> I understand and I am not pushing you to completing it, but at the same time I
> >> don't want to queue up behind it for long. I suspect the cost of porting
> >> lockless page cache on top of my patches should not be high, but I'll never know
> >> till I try :)
> >>
> > My point is, your patch adds big lock. Then, I don't have to do meaningless effort
> > to reduce lock.
> 
> My patch does not add a big lock, it moves the lock from struct
> page->page_cgroup to struct page_cgroup. The other locking added is the locking
> overhead associated with inserting entries into the radix tree, true. I ran
> oprofile along with lockdep and lockstats enabled on my patches. I don't see the
> radix_tree or page_cgroup->lock showing up, I see __slab_free and __slab_alloc
> showing up. I'll poke a little further.
> 
Hmm, one concern I have now is I don't see any contention on  res_counter->lock in
recent lock_stat test....which was usually on the top of list in past.
Did you see it ?

> Please don't let my patch stop you, we'll integrate the best of both worlds and
> what is good for memcg.
> 
Thank you.

To be honest, I wonder control via page_cgroup may be too rich for 32bit archs ;(.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
