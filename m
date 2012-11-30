Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id BA73C6B0075
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 23:10:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4CA9E3EE0C1
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:10:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FDB745DEBC
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:10:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1810345DEBA
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:10:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1E751DB803C
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:10:53 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A456C1DB8040
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:10:53 +0900 (JST)
Message-ID: <50B831BC.3050500@jp.fujitsu.com>
Date: Fri, 30 Nov 2012 13:10:36 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2 5/6] memcg: further simplify mem_cgroup_iter
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz> <1353955671-14385-6-git-send-email-mhocko@suse.cz>
In-Reply-To: <1353955671-14385-6-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

(2012/11/27 3:47), Michal Hocko wrote:
> mem_cgroup_iter basically does two things currently. It takes care of
> the house keeping (reference counting, raclaim cookie) and it iterates
> through a hierarchy tree (by using cgroup generic tree walk).
> The code would be much more easier to follow if we move the iteration
> outside of the function (to __mem_cgrou_iter_next) so the distinction
> is more clear.
> This patch doesn't introduce any functional changes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Very nice look !

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
