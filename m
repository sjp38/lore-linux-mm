Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2892C6B00E9
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 04:14:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5B1C13EE081
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:14:10 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F4DE45DE5A
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:14:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 238D245DE58
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:14:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13404E08001
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:14:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D1C9F1DB804D
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:14:09 +0900 (JST)
Date: Tue, 28 Jun 2011 17:06:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 14/22] memcg: fix direct softlimit reclaim to be called
 in limit path
Message-Id: <20110628170649.87043e05.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110628080847.GA16518@tiehlicka.suse.cz>
References: <201106272318.p5RNICJW001465@imap1.linux-foundation.org>
	<20110628080847.GA16518@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, nishimura@mxp.nes.nec.co.jp, yinghan@google.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 28 Jun 2011 10:08:47 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> I am sorry, that I am answering that late but I didn't get to this
> sooner.
> 
> On Mon 27-06-11 16:18:12, Andrew Morton wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > commit d149e3b ("memcg: add the soft_limit reclaim in global direct
> > reclaim") adds a softlimit hook to shrink_zones().  By this, soft limit is
> > called as
> > 
> >    try_to_free_pages()
> >        do_try_to_free_pages()
> >            shrink_zones()
> >                mem_cgroup_soft_limit_reclaim()
> > 
> > Then, direct reclaim is memcg softlimit hint aware, now.
> > 
> > But, the memory cgroup's "limit" path can call softlimit shrinker.
> > 
> >    try_to_free_mem_cgroup_pages()
> >        do_try_to_free_pages()
> >            shrink_zones()
> >                mem_cgroup_soft_limit_reclaim()
> > 
> > This will cause a global reclaim when a memcg hits limit.
> 
> Sorry, I do not get it. How does it cause the global reclaim? Did you
> mean soft reclaim?
> 

yes. soft reclaim does global reclaim (in some means). 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
