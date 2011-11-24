Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF666B008C
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 19:02:24 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A6DDF3EE0C0
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:02:20 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E10D45DF46
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:02:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5538F45DF52
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:02:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 414901DB8061
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:02:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E2E6C1DB8057
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:02:19 +0900 (JST)
Date: Thu, 24 Nov 2011 09:01:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 4/8] mm: memcg: lookup_page_cgroup (almost) never
 returns NULL
Message-Id: <20111124090112.93bde2b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322062951-1756-5-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-5-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Nov 2011 16:42:27 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Johannes Weiner <jweiner@redhat.com>
> 
> Pages have their corresponding page_cgroup descriptors set up before
> they are used in userspace, and thus managed by a memory cgroup.
> 
> The only time where lookup_page_cgroup() can return NULL is in the
> page sanity checking code that executes while feeding pages into the
> page allocator for the first time.
> 
> Remove the NULL checks against lookup_page_cgroup() results from all
> callsites where we know that corresponding page_cgroup descriptors
> must be allocated.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
