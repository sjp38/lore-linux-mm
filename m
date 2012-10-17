Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id C53D56B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 02:41:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DF85F3EE0BD
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:41:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBBA145DE58
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:41:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A22A345DE3E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:41:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F9321DB804F
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:41:33 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4072E1DB803F
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:41:33 +0900 (JST)
Message-ID: <507E52EE.7080706@jp.fujitsu.com>
Date: Wed, 17 Oct 2012 15:40:46 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 06/14] memcg: kmem controller infrastructure
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-7-git-send-email-glommer@parallels.com>
In-Reply-To: <1350382611-20579-7-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

(2012/10/16 19:16), Glauber Costa wrote:
> This patch introduces infrastructure for tracking kernel memory pages to
> a given memcg. This will happen whenever the caller includes the flag
> __GFP_KMEMCG flag, and the task belong to a memcg other than the root.
> 
> In memcontrol.h those functions are wrapped in inline acessors.  The
> idea is to later on, patch those with static branches, so we don't incur
> any overhead when no mem cgroups with limited kmem are being used.
> 
> Users of this functionality shall interact with the memcg core code
> through the following functions:
> 
> memcg_kmem_newpage_charge: will return true if the group can handle the
>                             allocation. At this point, struct page is not
>                             yet allocated.
> 
> memcg_kmem_commit_charge: will either revert the charge, if struct page
>                            allocation failed, or embed memcg information
>                            into page_cgroup.
> 
> memcg_kmem_uncharge_page: called at free time, will revert the charge.
> 
> [ v2: improved comments and standardized function names ]
> [ v3: handle no longer opaque, functions not exported,
>    even more comments ]
> [ v4: reworked Used bit handling and surroundings for more clarity ]
> [ v5: simplified code for kmemcg compiled out and core functions in
>    memcontrol.c, moved kmem code to the middle to avoid forward decls ]
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Tejun Heo <tj@kernel.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
