Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 9A2326B00E8
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:42:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C30C13EE0BC
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:42:17 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA3D945DE59
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:42:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9180045DE58
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:42:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 84EA4E08007
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:42:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C2D2E08002
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:42:17 +0900 (JST)
Message-ID: <4FB0E119.7040103@jp.fujitsu.com>
Date: Mon, 14 May 2012 19:40:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm/memcg: apply add/del_page to lruvec
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils> <alpine.LSU.2.00.1205132201210.6148@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205132201210.6148@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/05/14 14:02), Hugh Dickins wrote:

> Take lruvec further: pass it instead of zone to add_page_to_lru_list()
> and del_page_from_lru_list(); and pagevec_lru_move_fn() pass lruvec
> down to its target functions.
> 
> This cleanup eliminates a swathe of cruft in memcontrol.c,
> including mem_cgroup_lru_add_list(), mem_cgroup_lru_del_list() and
> mem_cgroup_lru_move_lists() - which never actually touched the lists.
> 
> In their place, mem_cgroup_page_lruvec() to decide the lruvec,
> previously a side-effect of add, and mem_cgroup_update_lru_size()
> to maintain the lru_size stats.
> 
> Whilst these are simplifications in their own right, the goal is to
> bring the evaluation of lruvec next to the spin_locking of the lrus,
> in preparation for a future patch.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
