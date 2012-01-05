Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id DC2326B0068
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 01:35:00 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 72F7E3EE0BC
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:34:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59F1B45DE53
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:34:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 41EED45DE50
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:34:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 31E3E1DB803F
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:34:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC71F1DB8037
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:34:58 +0900 (JST)
Date: Thu, 5 Jan 2012 15:33:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
Message-Id: <20120105153344.8c6682fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112312329240.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
	<alpine.LSU.2.00.1112312329240.18500@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Sat, 31 Dec 2011 23:30:38 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> I never understood why we need a MEM_CGROUP_ZSTAT(mz, idx) macro
> to obscure the LRU counts.  For easier searching?  So call it
> lru_size rather than bare count (lru_length sounds better, but
> would be wrong, since each huge page raises lru_size hugely).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, can this counter be moved to lruvec finally ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
