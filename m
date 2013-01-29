Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 36EDF6B000D
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:22:25 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 73AA63EE0B5
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:22:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B89745DE5B
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:22:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E7C945DE59
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:22:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E30D1DB8055
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:22:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C65821DB8044
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:22:22 +0900 (JST)
Message-ID: <51071631.5060503@jp.fujitsu.com>
Date: Tue, 29 Jan 2013 09:22:09 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 6/6] memcg: avoid dangling reference count in creation
 failure.
References: <1358862461-18046-1-git-send-email-glommer@parallels.com> <1358862461-18046-7-git-send-email-glommer@parallels.com>
In-Reply-To: <1358862461-18046-7-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/01/22 22:47), Glauber Costa wrote:
> When use_hierarchy is enabled, we acquire an extra reference count
> in our parent during cgroup creation. We don't release it, though,
> if any failure exist in the creation process.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reported-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
