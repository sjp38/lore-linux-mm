Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 45D4C6B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 01:18:38 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 31FB13EE0B6
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:18:36 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13FDA45DE63
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:18:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EE74545DE5D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:18:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE5C81DB8052
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:18:35 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9486C1DB804E
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:18:35 +0900 (JST)
Message-ID: <50EA689B.7060308@jp.fujitsu.com>
Date: Mon, 07 Jan 2013 15:18:03 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz> <1357235661-29564-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1357235661-29564-5-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

(2013/01/04 2:54), Michal Hocko wrote:
> Now that per-node-zone-priority iterator caches memory cgroups rather
> than their css ids we have to be careful and remove them from the
> iterator when they are on the way out otherwise they might hang for
> unbounded amount of time (until the global/targeted reclaim triggers the
> zone under priority to find out the group is dead and let it to find the
> final rest).
> 
> This is solved by hooking into mem_cgroup_css_offline and checking all
> per-node-zone-priority iterators up the way to the root cgroup. If the
> current memcg is found in the respective iter->last_visited then it is
> replaced by the previous one in the same sub-hierarchy.
> 
> This guarantees that no group gets more reclaiming than necessary and
> the next iteration will continue without noticing that the removed group
> has disappeared.
> 
> Spotted-by: Ying Han <yinghan@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
