Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7C09000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 04:06:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E44733EE0C1
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 17:06:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C339F3266C2
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 17:06:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB5893E6101
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 17:06:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A0ED1DB8053
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 17:06:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 635FA1DB804E
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 17:06:04 +0900 (JST)
Date: Fri, 30 Sep 2011 17:05:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 00/10] memcg naturalization -rc4
Message-Id: <20110930170510.4695b8f0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
References: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 29 Sep 2011 23:00:54 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Hi,
> 
> this is the fourth revision of the memory cgroup naturalization
> series.
> 
> The changes from v3 have mostly been documentation, changelog, and
> naming fixes based on review feedback:
> 
>     o drop conversion of no longer existing zone-wide unevictable
>       page rescue scanner
>     o fix return value of mem_cgroup_hierarchical_reclaim() in
>       limit-shrinking mode (Michal)
>     o rename @remember to @reclaim in mem_cgroup_iter()
>     o convert vm_swappiness to global_reclaim() in the
>       correct patch (Michal)
>     o rename
>       struct mem_cgroup_iter_state -> struct mem_cgroup_reclaim_iter
>       and
>       struct mem_cgroup_iter -> struct mem_cgroup_reclaim_cookie
>       (Michal)
>     o added/amended comments and changelogs based on feedback (Michal, Kame)
> 
> Thanks for the review and feedback, guys, it's much appreciated!
> 

Thank you for your work. Now, I'm ok this series to be tested in -mm.
Ack. to all.

Do you have any plan, concerns ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
