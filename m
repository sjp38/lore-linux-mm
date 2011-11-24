Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 381946B008C
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 19:10:21 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D08E83EE0AE
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:10:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B7FAC45DF49
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:10:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A1CE345DF48
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:10:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 968521DB804B
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:10:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6491D1DB8050
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:10:18 +0900 (JST)
Date: Thu, 24 Nov 2011 09:09:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 7/8] mm: memcg: modify PageCgroupAcctLRU non-atomically
Message-Id: <20111124090915.2f6e2e2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322062951-1756-8-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-8-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Nov 2011 16:42:30 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Johannes Weiner <jweiner@redhat.com>
> 
> This bit is protected by zone->lru_lock, there is no need for locked
> operations when setting and clearing it.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

This atomic ops are for avoiding race with other ops as lock_page_cgroup().
Or other Set/ClearPageCgroup....

Do I misunderstand atomic ops v.s. non-atomic ops race ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
