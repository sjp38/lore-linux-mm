Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 4C56D6B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 00:41:10 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C6B443EE0AE
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:41:08 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE69145DE51
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:41:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 967AC45DE4F
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:41:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 897AF1DB8037
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:41:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 407B71DB803F
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:41:08 +0900 (JST)
Date: Thu, 8 Mar 2012 14:39:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm, memcg: pass charge order to oom killer
Message-Id: <20120308143935.d38318f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1203071341320.4520@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203071341320.4520@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 Mar 2012 13:43:05 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> The oom killer typically displays the allocation order at the time of oom
> as a part of its diangostic messages (for global, cpuset, and mempolicy
> ooms).
> 
> The memory controller may also pass the charge order to the oom killer so
> it can emit the same information.  This is useful in determining how
> large the memory allocation is that triggered the oom killer.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Now, usual memcg only supports 1 page allocation.
(If hugetlb allocation failed, it will use a normal page allocation.)

But it seems there are(will be) changes because of tcp buffer control or
slab accounting.
 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
