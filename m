Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 4377A6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:58:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7B92F3EE0BC
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:58:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5474145DEBB
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:58:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 14C6A45DEB6
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:58:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 02B061DB803E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:58:09 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A4C1C1DB803C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:58:08 +0900 (JST)
Message-ID: <516383AD.9010305@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 11:57:49 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/12] memcg: don't need to free memcg via RCU or workqueue
References: <5162648B.9070802@huawei.com> <51626570.8000400@huawei.com>
In-Reply-To: <51626570.8000400@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

(2013/04/08 15:36), Li Zefan wrote:
> Now memcg has the same life cycle with its corresponding cgroup, and
> a cgroup is freed via RCU and then mem_cgroup_css_free() is called
> in a work function, so we can simply call __mem_cgroup_free() in
> mem_cgroup_css_free().
> 
> This actually reverts 59927fb984de1703c67bc640c3e522d8b5276c73
> ("memcg: free mem_cgroup by RCU to fix oops").
> 
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Very nice.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
