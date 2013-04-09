Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id A84C86B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 00:12:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1A7BB3EE0BD
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 13:12:02 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F3DAB45DE5E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 13:12:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CFBA245DE58
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 13:12:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B701BE08005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 13:12:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A5EA1DB804B
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 13:12:01 +0900 (JST)
Message-ID: <516394FE.7090603@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 13:11:42 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] memcg: don't use css_id any more
References: <51627DA9.7020507@huawei.com> <51627E74.5020300@huawei.com>
In-Reply-To: <51627E74.5020300@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2013/04/08 17:23), Li Zefan wrote:
> Now memcg uses cgroup->id instead of css_id. Update some comments and
> set mem_cgroup_subsys->use_id to 0.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
