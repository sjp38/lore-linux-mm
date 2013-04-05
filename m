Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 226476B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:23:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 28AD53EE0C0
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:23:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C91E45DEBB
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:23:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E9C2D45DEBA
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:23:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D23EBE08005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:23:32 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 829BA1DB803C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:23:32 +0900 (JST)
Message-ID: <515E97E1.3070208@jp.fujitsu.com>
Date: Fri, 05 Apr 2013 18:22:41 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/7] memcg: don't need to get a reference to the
 parent
References: <515BF233.6070308@huawei.com> <515BF2B1.9060909@huawei.com>
In-Reply-To: <515BF2B1.9060909@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/04/03 18:13), Li Zefan wrote:
> The cgroup core guarantees it's always safe to access the parent.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
