Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 15ED46B0027
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:16:30 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A8AD93EE0BD
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:16:28 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E2FD45DEB5
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:16:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 754B545DEBB
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:16:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C99A1DB803E
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:16:28 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ECE021DB8043
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:16:27 +0900 (JST)
Message-ID: <510714D0.2030206@jp.fujitsu.com>
Date: Tue, 29 Jan 2013 09:16:16 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 4/6] memcg: replace cgroup_lock with memcg specific
 memcg_lock
References: <1358862461-18046-1-git-send-email-glommer@parallels.com> <1358862461-18046-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1358862461-18046-5-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/01/22 22:47), Glauber Costa wrote:
> After the preparation work done in earlier patches, the cgroup_lock can
> be trivially replaced with a memcg-specific lock. This is an automatic
> translation in every site the values involved were queried.
> 
> The sites were values are written, however, used to be naturally called
> under cgroup_lock. This is the case for instance of the css_online
> callback. For those, we now need to explicitly add the memcg lock.
> 
> With this, all the calls to cgroup_lock outside cgroup core are gone.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
