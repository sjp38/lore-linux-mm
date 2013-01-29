Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 14D1A6B0028
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:12:51 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2DAAD3EE0AE
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:12:49 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 117C445DE59
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:12:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EBBB645DE54
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:12:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5D5FE08002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:12:48 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CF1B1DB802F
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:12:48 +0900 (JST)
Message-ID: <510713F3.9040207@jp.fujitsu.com>
Date: Tue, 29 Jan 2013 09:12:35 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/6] memcg: split part of memcg creation to css_online
References: <1358862461-18046-1-git-send-email-glommer@parallels.com> <1358862461-18046-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1358862461-18046-3-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/01/22 22:47), Glauber Costa wrote:
> This patch is a preparatory work for later locking rework to get rid of
> big cgroup lock from memory controller code.
> 
> The memory controller uses some tunables to adjust its operation. Those
> tunables are inherited from parent to children upon children
> intialization. For most of them, the value cannot be changed after the
> parent has a new children.
> 
> cgroup core splits initialization in two phases: css_alloc and css_online.
> After css_alloc, the memory allocation and basic initialization are
> done. But the new group is not yet visible anywhere, not even for cgroup
> core code. It is only somewhere between css_alloc and css_online that it
> is inserted into the internal children lists. Copying tunable values in
> css_alloc will lead to inconsistent values: the children will copy the
> old parent values, that can change between the copy and the moment in
> which the groups is linked to any data structure that can indicate the
> presence of children.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
