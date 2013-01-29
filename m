Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 03EDC6B0028
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:18:40 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AF7293EE0B5
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:18:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 99D0D45DE52
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:18:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8240D45DE4D
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:18:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 760551DB802F
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:18:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A3A71DB803B
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:18:39 +0900 (JST)
Message-ID: <51071551.8040903@jp.fujitsu.com>
Date: Tue, 29 Jan 2013 09:18:25 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 5/6] memcg: increment static branch right after limit
 set.
References: <1358862461-18046-1-git-send-email-glommer@parallels.com> <1358862461-18046-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1358862461-18046-6-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/01/22 22:47), Glauber Costa wrote:
> We were deferring the kmemcg static branch increment to a later time,
> due to a nasty dependency between the cpu_hotplug lock, taken by the
> jump label update, and the cgroup_lock.
> 
> Now we no longer take the cgroup lock, and we can save ourselves the
> trouble.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
