Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E7A936B00C0
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:08:14 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1126D3EE0B6
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:08:13 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E8AC845DE5A
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:08:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CCBA445DE56
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:08:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B99151DB8051
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:08:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7447F1DB8042
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:08:12 +0900 (JST)
Message-ID: <4FD598C2.8020709@jp.fujitsu.com>
Date: Mon, 11 Jun 2012 16:05:38 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix use_hierarchy css_is_ancestor oops regression
References: <alpine.LSU.2.00.1206101150230.4239@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1206101150230.4239@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/06/11 3:54), Hugh Dickins wrote:
> If use_hierarchy is set, reclaim testing soon oopses in css_is_ancestor()
> called from __mem_cgroup_same_or_subtree() called from page_referenced():
> when processes are exiting, it's easy for mm_match_cgroup() to pass along
> a NULL memcg coming from a NULL mm->owner.
>
> Check for that in __mem_cgroup_same_or_subtree().  Return true or false?
> False because we cannot know if it was in the hierarchy, but also false
> because it's better not to count a reference from an exiting process.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
