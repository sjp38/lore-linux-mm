Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 701F36B0028
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:15:06 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 23FE23EE0BD
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:15:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B0E245DE4F
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:15:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E844045DE4D
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:15:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D9A9CE08004
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:15:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87C231DB802F
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:15:04 +0900 (JST)
Message-ID: <5107147B.9080805@jp.fujitsu.com>
Date: Tue, 29 Jan 2013 09:14:51 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3/6] memcg: fast hierarchy-aware child test.
References: <1358862461-18046-1-git-send-email-glommer@parallels.com> <1358862461-18046-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1358862461-18046-4-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/01/22 22:47), Glauber Costa wrote:
> Currently, we use cgroups' provided list of children to verify if it is
> safe to proceed with any value change that is dependent on the cgroup
> being empty.
> 
> This is less than ideal, because it enforces a dependency over cgroup
> core that we would be better off without. The solution proposed here is
> to iterate over the child cgroups and if any is found that is already
> online, we bounce and return: we don't really care how many children we
> have, only if we have any.
> 
> This is also made to be hierarchy aware. IOW, cgroups with  hierarchy
> disabled, while they still exist, will be considered for the purpose of
> this interface as having no children.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
