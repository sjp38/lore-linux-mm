Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id AF4646B0012
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 03:25:22 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5082F3EE0B5
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:25:21 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 350D245DE5B
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:25:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DAFC45DE58
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:25:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E4A61DB804C
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:25:21 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B1BA0E08002
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:25:20 +0900 (JST)
Message-ID: <511DF0DA.7020906@jp.fujitsu.com>
Date: Fri, 15 Feb 2013 17:24:58 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 4/6] memcg: simplify mem_cgroup_iter
References: <1360848396-16564-1-git-send-email-mhocko@suse.cz> <1360848396-16564-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1360848396-16564-5-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

(2013/02/14 22:26), Michal Hocko wrote:
> Current implementation of mem_cgroup_iter has to consider both css and
> memcg to find out whether no group has been found (css==NULL - aka the
> loop is completed) and that no memcg is associated with the found node
> (!memcg - aka css_tryget failed because the group is no longer alive).
> This leads to awkward tweaks like tests for css && !memcg to skip the
> current node.
> 
> It will be much easier if we got rid off css variable altogether and
> only rely on memcg. In order to do that the iteration part has to skip
> dead nodes. This sounds natural to me and as a nice side effect we will
> get a simple invariant that memcg is always alive when non-NULL and all
> nodes have been visited otherwise.
> 
> We could get rid of the surrounding while loop but keep it in for now to
> make review easier. It will go away in the following patch.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
nice.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
