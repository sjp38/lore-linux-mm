Date: Tue, 05 Aug 2008 15:20:59 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Race condition between putback_lru_page and mem_cgroup_move_list
In-Reply-To: <489741F8.2080104@linux.vnet.ibm.com>
References: <2f11576a0808040937y70f274e0j32f6b9c98b0f992d@mail.gmail.com> <489741F8.2080104@linux.vnet.ibm.com>
Message-Id: <20080805151956.A885.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, MinChan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Balbir-san,

> > I also think zone's lru lock is unnecessary.
> > So, I guess below "it" indicate lock_page_cgroup, not zone lru lock.
> 
> We need zone LRU lock, since the reclaim paths hold them. Not sure if I
> understand why you call zone's LRU lock unnecessary, could you elaborate please?

I tought..

1. in general, one data structure should be protected by one lock.
2. memcgroup lru is protected by mem_cgroup_per_zone::lru_lock.


if zone LRU lock must be held, Why do mem_cgroup_per_zone::lru_lock exit?
it should be removed?


Could you explain detail of "race condition with global reclaim race" ?



> > I think both opinion is correct.
> > unevictable lru related code doesn't require pagevec.
> > 
> > but mem_cgroup_move_lists is used by active/inactive list transition too.
> > then, pagevec is necessary for keeping reclaim throuput.
> > 
> 
> It's on my TODO list. I hope to get to it soon.

Very good news!
Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
