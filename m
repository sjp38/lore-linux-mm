Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6FFB56B0068
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 23:09:22 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CA7153EE0C5
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:09:20 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B395745DE51
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:09:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D91845DE52
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:09:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8031E1DB803E
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:09:20 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A2101DB8037
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:09:20 +0900 (JST)
Message-ID: <50B8315E.6090908@jp.fujitsu.com>
Date: Fri, 30 Nov 2012 13:09:02 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2 4/6] memcg: simplify mem_cgroup_iter
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz> <1353955671-14385-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1353955671-14385-5-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

(2012/11/27 3:47), Michal Hocko wrote:
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

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
