Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m75AkXvR023477
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 20:46:33 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m75AktwF2781202
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 20:46:56 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m75AktZV001947
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 20:46:55 +1000
Message-ID: <48982F9E.2080100@linux.vnet.ibm.com>
Date: Tue, 05 Aug 2008 16:16:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Race condition between putback_lru_page and mem_cgroup_move_list
References: <2f11576a0808040937y70f274e0j32f6b9c98b0f992d@mail.gmail.com> <489741F8.2080104@linux.vnet.ibm.com> <20080805151956.A885.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080805151956.A885.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, MinChan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi Balbir-san,
> 
>>> I also think zone's lru lock is unnecessary.
>>> So, I guess below "it" indicate lock_page_cgroup, not zone lru lock.
>> We need zone LRU lock, since the reclaim paths hold them. Not sure if I
>> understand why you call zone's LRU lock unnecessary, could you elaborate please?
> 
> I tought..
> 
> 1. in general, one data structure should be protected by one lock.

In general yes, but in practice no. We have different paths through which a page
can be reclaimed. Consider the following

1. What happens if a global reclaim is in progress at the same time as memory
cgroup reclaim and they are both looking at the same page?
2. In the shared reclaim infrastructure, we move pages and update statistics for
pages belonging to a particular zone in a particular cgroup.

>> It's on my TODO list. I hope to get to it soon.
> 
> Very good news!

I hope they show the benefit that I expect them too :)

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
