Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id ACAFB6B0083
	for <linux-mm@kvack.org>; Sun, 25 Mar 2012 21:15:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8214E3EE0B6
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:15:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 60D9245DE50
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:15:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4879645DE4D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:15:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C3271DB802C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:15:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAEA91DB803A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 10:15:13 +0900 (JST)
Message-ID: <4F6FC2C0.6090809@jp.fujitsu.com>
Date: Mon, 26 Mar 2012 10:13:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg swap: use mem_cgroup_uncharge_swap
References: <alpine.LSU.2.00.1203231351310.1940@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1203231351310.1940@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

(2012/03/24 5:54), Hugh Dickins wrote:

> That stuff __mem_cgroup_commit_charge_swapin() does with a swap entry,
> it has a name and even a declaration: just use mem_cgroup_uncharge_swap().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>


Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
