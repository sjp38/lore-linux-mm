Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 5C7346B0071
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 08:22:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E7FE03EE0BD
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:22:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C92DC45DE5B
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:22:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C04745DE58
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:22:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C04C1DB8058
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:22:03 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CF421DB8055
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 21:22:03 +0900 (JST)
Message-ID: <4FDF1CE5.90803@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 21:19:49 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 17/25] skip memcg kmem allocations in specified code
 regions
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-18-git-send-email-glommer@parallels.com>
In-Reply-To: <1340015298-14133-18-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2012/06/18 19:28), Glauber Costa wrote:
> This patch creates a mechanism that skip memcg allocations during
> certain pieces of our core code. It basically works in the same way
> as preempt_disable()/preempt_enable(): By marking a region under
> which all allocations will be accounted to the root memcg.
> 
> We need this to prevent races in early cache creation, when we
> allocate data using caches that are not necessarily created already.
> 
> Signed-off-by: Glauber Costa<glommer@parallels.com>
> CC: Christoph Lameter<cl@linux.com>
> CC: Pekka Enberg<penberg@cs.helsinki.fi>
> CC: Michal Hocko<mhocko@suse.cz>
> CC: Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner<hannes@cmpxchg.org>
> CC: Suleiman Souhlal<suleiman@google.com>

I'm ok with this approach.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
