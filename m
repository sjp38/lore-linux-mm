Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD066B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 18:43:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BA4343EE0AE
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 08:43:51 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F69845DEB4
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 08:43:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8492745DEAD
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 08:43:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 768C71DB803F
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 08:43:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E3E91DB803B
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 08:43:51 +0900 (JST)
Date: Wed, 30 Nov 2011 08:42:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 5/7] mm: page_cgroup: check page_cgroup arrays in
 lookup_page_cgroup() only when necessary
Message-Id: <20111130084211.15fdefbf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322563925-1667-6-git-send-email-hannes@cmpxchg.org>
References: <1322563925-1667-1-git-send-email-hannes@cmpxchg.org>
	<1322563925-1667-6-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 29 Nov 2011 11:52:03 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> lookup_page_cgroup() is usually used only against pages that are used
> in userspace.
> 
> The exception is the CONFIG_DEBUG_VM-only memcg check from the page
> allocator: it can run on pages without page_cgroup descriptors
> allocated when the pages are fed into the page allocator for the first
> time during boot or memory hotplug.
> 
> Include the array check only when CONFIG_DEBUG_VM is set and save the
> unnecessary check in production kernels.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
