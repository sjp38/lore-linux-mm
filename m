Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 805C08D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:06:38 -0400 (EDT)
Date: Thu, 31 Mar 2011 22:06:25 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
Message-ID: <20110331200625.GB4670@cmpxchg.org>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110331155931.GG12265@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110331155931.GG12265@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lsf@lists.linux-foundation.org, linux-mm@kvack.org

On Thu, Mar 31, 2011 at 05:59:31PM +0200, Andrea Arcangeli wrote:
> On Thu, Mar 31, 2011 at 11:01:13AM +0900, KAMEZAWA Hiroyuki wrote:
> >   III) Discussing the current and future design of LRU.(for 30+min)
> > 
> >   IV) Diet of page_cgroup (for 30-min)
> >       Maybe this can be combined with III.
> 
> Looks a good plan to me, but others are more directly involved in
> memcg than me so feel free to decide! About the diet topic it was
> suggested by Johannes so I'll let him comment on it if he wants.

I suspect that we will discuss the removal of the global LRU in III,
so that would cover a major part of the diet, removing the list head.

That leaves the ideas of integrating the remaining flags field and the
mem_cgroup pointer into struct page (without increasing its size) as a
separate topic that does not fit into III, but which I would like to
discuss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
