Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 36F4C6B0027
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 01:05:45 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5B0003EE0BB
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:05:43 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 41D5245DE50
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:05:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C45E45DE4E
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:05:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F64E1DB803F
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:05:43 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5D2F1DB8037
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:05:42 +0900 (JST)
Message-ID: <51591594.5070905@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 14:05:24 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: avoid accessing memcg after releasing reference
References: <5158F344.9020509@huawei.com>
In-Reply-To: <5158F344.9020509@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

(2013/04/01 11:39), Li Zefan wrote:
> This might cause use-after-free bug.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
