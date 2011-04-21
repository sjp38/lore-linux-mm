Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2F27C8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:48:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DF3FD3EE0BD
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:47:59 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C09F245DE97
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:47:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A7D4E45DE92
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:47:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BF8FE18003
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:47:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 69757E08001
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:47:59 +0900 (JST)
Date: Thu, 21 Apr 2011 12:40:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-Id: <20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Mon, 18 Apr 2011 20:57:36 -0700
Ying Han <yinghan@google.com> wrote:

> 1. there are one kswapd thread per cgroup. the thread is created when the
> cgroup changes its limit_in_bytes and is deleted when the cgroup is being
> removed. In some enviroment when thousand of cgroups are being configured on
> a single host, we will have thousand of kswapd threads. The memory consumption
> would be 8k*100 = 8M. We don't see a big issue for now if the host can host
> that many of cgroups.
> 

I don't think no-fix to this is ok.

Here is a thread pool patch on your set. (and includes some more).
3 patches in following e-mails.
Any comments are welocme, but my response may be delayed.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
