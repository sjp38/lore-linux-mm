Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id C6C1D6B0036
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:24:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4CD713EE081
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:24:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 33EA645DE5A
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:24:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 17E2545DE53
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:24:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 01E371DB8047
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:24:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A581C1DB8041
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:24:33 +0900 (JST)
Message-ID: <515E9831.5060508@jp.fujitsu.com>
Date: Fri, 05 Apr 2013 18:24:01 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 7/7] memcg: kill memcg refcnt
References: <515BF233.6070308@huawei.com> <515BF2E3.4000605@huawei.com>
In-Reply-To: <515BF2E3.4000605@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/04/03 18:14), Li Zefan wrote:
> Now memcg has the same life cycle as the corresponding cgroup.
> Kill the useless refcnt.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

very very very nice. Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
