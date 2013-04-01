Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id AACD76B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 01:03:50 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CF35D3EE0C1
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:03:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B5A5D45DE5C
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:03:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E43945DE5A
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:03:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BF121DB8047
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:03:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 434C11DB8042
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:03:48 +0900 (JST)
Message-ID: <5159151E.9070204@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 14:03:26 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: take reference before releasing rcu_read_lock
References: <51556CE9.9060000@huawei.com>
In-Reply-To: <51556CE9.9060000@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

(2013/03/29 19:28), Li Zefan wrote:
> The memcg is not referenced, so it can be destroyed at anytime right
> after we exit rcu read section, so it's not safe to access it.
> 
> To fix this, we call css_tryget() to get a reference while we're still
> in rcu read section.
> 
> This also removes a bogus comment above __memcg_create_cache_enqueue().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
