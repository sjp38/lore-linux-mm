Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 26BF56B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:59:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B31A63EE0BD
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:59:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AE1045DE54
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:59:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 80BBA45DE51
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:59:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7138B1DB8042
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:59:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2656C1DB803E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:59:57 +0900 (JST)
Message-ID: <5163922A.9050404@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 12:59:38 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] memcg: convert to use cgroup_from_id()
References: <51627DA9.7020507@huawei.com> <51627E09.5010605@huawei.com>
In-Reply-To: <51627E09.5010605@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2013/04/08 17:21), Li Zefan wrote:
> This is a preparation to kill css_id.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>   mm/memcontrol.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)

Acked-by: KAMEZAWA Hiroyoku <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
