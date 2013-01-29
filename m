Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id EE5556B0027
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:11:19 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 781EF3EE0BB
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:11:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 578F745DE53
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:11:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4376545DE4F
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:11:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 334FFE08002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:11:18 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DF0B71DB803B
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:11:17 +0900 (JST)
Message-ID: <51071397.2080908@jp.fujitsu.com>
Date: Tue, 29 Jan 2013 09:11:03 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/6] memcg: prevent changes to move_charge_at_immigrate
 during task attach
References: <1358862461-18046-1-git-send-email-glommer@parallels.com> <1358862461-18046-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1358862461-18046-2-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/01/22 22:47), Glauber Costa wrote:
> Currently, we rely on the cgroup_lock() to prevent changes to
> move_charge_at_immigrate during task migration. However, this is only
> needed because the current strategy keeps checking this value throughout
> the whole process. Since all we need is serialization, one needs only to
> guarantee that whatever decision we made in the beginning of a specific
> migration is respected throughout the process.
> 
> We can achieve this by just saving it in mc. By doing this, no kind of
> locking is needed.
> 
> [ v2: change flag name to avoid confusion ]
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
