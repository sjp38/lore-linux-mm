Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0F71B6B008C
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 19:14:36 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 95E603EE081
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:14:34 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B5872AEA95
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:14:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6216245DF48
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:14:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52AE41DB8057
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:14:34 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CF571DB8050
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:14:34 +0900 (JST)
Date: Thu, 24 Nov 2011 09:13:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 8/8] mm: memcg: modify PageCgroupCache non-atomically
Message-Id: <20111124091328.d28d9f55.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322062951-1756-9-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-9-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Nov 2011 16:42:31 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Johannes Weiner <jweiner@redhat.com>
> 
> This bit is protected by lock_page_cgroup(), there is no need for
> locked operations when setting and clearing it.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Hm. non-atomic ops for pc->flags seems dangerous.
How about try to remove PCG_CACHE ? Maybe we can depends on PageAnon(page).
We see 'page' on memcg->lru now.
I'm sorry I forgot why we needed PCG_CACHE flag..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
