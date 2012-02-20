Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id BFD366B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 03:56:19 -0500 (EST)
Date: Mon, 20 Feb 2012 09:56:17 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/6] memcg: remove PCG_MOVE_LOCK flag from page_cgroup
Message-ID: <20120220085617.GC1677@cmpxchg.org>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
 <20120217182651.c12bfc5e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120217182651.c12bfc5e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

On Fri, Feb 17, 2012 at 06:26:51PM +0900, KAMEZAWA Hiroyuki wrote:
> >From 62a96c625be0c30fc5828d88685b6873ed254060 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 11:49:59 +0900
> Subject: [PATCH 3/6] memcg: remove PCG_MOVE_LOCK flag from page_cgroup.
> 
> PCG_MOVE_LOCK is used for bit spinlock to avoid race between overwriting
> pc->mem_cgroup and page statistics accounting per memcg.
> This lock helps to avoid the race but the race is very rare because moving
> tasks between cgroup is not a usual job.
> So, it seems using 1bit per page is too costly.
> 
> This patch changes this lock as per-memcg spinlock and removes PCG_MOVE_LOCK.
> 
> If smaller lock is required, we'll be able to add some hashes but
> I'd like to start from this.
> 
> Changelog:
>   - fixed to pass memcg as an argument rather than page_cgroup.
>     and renamed from move_lock_page_cgroup() to move_lock_mem_cgroup()
> 
> Acked-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
