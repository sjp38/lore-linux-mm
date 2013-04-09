Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id E8D086B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:53:37 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3B4CB3EE0BD
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:53:36 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D02745DE5B
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:53:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4AC545DE56
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:53:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4A5EE08001
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:53:35 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D1B51DB804A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:53:35 +0900 (JST)
Message-ID: <5163829C.3030809@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 11:53:16 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/12] memcg: don't use mem_cgroup_get() when creating
 a kmemcg cache
References: <5162648B.9070802@huawei.com> <516264F1.8020904@huawei.com>
In-Reply-To: <516264F1.8020904@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2013/04/08 15:34), Li Zefan wrote:
> Use css_get()/css_put() instead of mem_cgroup_get()/mem_cgroup_put().
> 
> There are two things being done in the current code:
> 
> First, we acquired a css_ref to make sure that the underlying cgroup
> would not go away. That is a short lived reference, and it is put as
> soon as the cache is created.
> 
> At this point, we acquire a long-lived per-cache memcg reference count
> to guarantee that the memcg will still be alive.
> 
> so it is:
> 
> enqueue: css_get
> create : memcg_get, css_put
> destroy: memcg_put
> 
> So we only need to get rid of the memcg_get, change the memcg_put to
> css_put, and get rid of the now extra css_put.
> 
> (This changelog is basically written by Glauber)
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
