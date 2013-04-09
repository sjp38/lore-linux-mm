Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id CBA236B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:50:27 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 456473EE0C7
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:50:26 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E55E45DD78
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:50:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BB0645DE4D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:50:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F2B231DB803C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:50:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A6A3A1DB803E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:50:25 +0900 (JST)
Message-ID: <516381DD.8050706@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 11:50:05 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/12] Revert "memcg: avoid dangling reference count in
 creation failure."
References: <5162648B.9070802@huawei.com> <516264BF.2020009@huawei.com>
In-Reply-To: <516264BF.2020009@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2013/04/08 15:33), Li Zefan wrote:
> From: Michal Hocko <mhocko@suse.cz>
> 
> This reverts commit e4715f01be697a3730c78f8ffffb595591d6a88c
> 
> mem_cgroup_put is hierarchy aware so mem_cgroup_put(memcg) already drops
> an additional reference from all parents so the additional
> mem_cgrroup_put(parent) potentially causes use-after-free.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
