Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3998D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 21:22:44 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BCF6C3EE0BC
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:22:40 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A0B2245DE61
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:22:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 861F345DD73
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:22:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 765801DB803C
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:22:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3809F1DB8038
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:22:40 +0900 (JST)
Date: Fri, 1 Apr 2011 10:16:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
Message-Id: <20110401101613.de0e79dc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org

On Thu, 31 Mar 2011 11:01:13 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> So, for this slot, I'd like to discuss
> 
>   I) Softlimit/Isolation (was 3-A) for 1hour
>      If we have extra time, kernel memory accounting or file-cache handling
>      will be good.
>    
>   II) Dirty page handling. (for 30min)
>      Maybe we'll discuss about per-memcg inode queueing issue.
> 
>   III) Discussing the current and future design of LRU.(for 30+min)
> 
>   IV) Diet of page_cgroup (for 30-min)
>       Maybe this can be combined with III.
> 

Thank you for feedbacks. I think I don't have enough time to reply all..
So, I'm sorry I make a reply in this style.

Hearing your replies and other private feedbacks, I think following schedule
will be good. And I want to spend time for topics for which patches are
posted and someone measured the cost and benefits.

1) How memcg users uses it and what's wanted ?  (for 1st session/30min)

   At start, we should sort out what's wanted as functions of memcg.
   We need to hear use cases. And see what is the problem, now. 
   Maybe we can discuss requirements for kernel memory limit, here.
   (I think we have no time to discuss implemenation in official slot.)

2) What's next ? : 30min.
   At first, Pavel will explain what OpenVZ does.
   Then, we can discuss about softlimit/isolation and LRU design.
   I think it will be a hot topic in the next half year with dirty page handling.
   
3) Dirty Page Handling.

4) Discussing LRU, costs and fairness.
   At first, need to discuss effect of per-memcg background reclaim.
   Then, discuss about new LRU design including removing page_cgroup->lru.
 
5) Diet of page_cgroup and others.
   I don't think diet topic requires full 30min. So, some extra topic is....
   It seems some guys want to overcommit vmem size with cgroup.


A topic from me was adding a memcg only-for-file-cache...but I have no patches.
Postphone until I have a concrete idea and patches.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
