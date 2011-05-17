Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2182D8D004A
	for <linux-mm@kvack.org>; Tue, 17 May 2011 19:59:48 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E49763EE0CB
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:59:44 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCEE945DEA0
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:59:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 913AA45DE9B
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:59:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E1A6E18008
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:59:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36346E18004
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:59:44 +0900 (JST)
Date: Wed, 18 May 2011 08:52:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: add memory.numastat api for numa statistics
Message-Id: <20110518085258.98f07390.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305671151-21993-2-git-send-email-yinghan@google.com>
References: <1305671151-21993-1-git-send-email-yinghan@google.com>
	<1305671151-21993-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Tue, 17 May 2011 15:25:51 -0700
Ying Han <yinghan@google.com> wrote:

> The new API exports numa_maps per-memcg basis. This is a piece of useful
> information where it exports per-memcg page distribution across real numa
> nodes.
> 
> One of the usecase is evaluating application performance by combining this
> information w/ the cpu allocation to the application.
> 
> The output of the memory.numastat tries to follow w/ simiar format of numa_maps
> like:
> 
> <total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> 
> $ cat /dev/cgroup/memory/memory.numa_stat
> 292115 N0=36364 N1=166876 N2=39741 N3=49115
> 
> Note: I noticed <total pages> is not equal to the sum of the rest of counters.
> I might need to change the way get that counter, comments are welcomed.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Hmm, If I'm a user, I want to know file-cache is well balanced or where Anon is
allocated from....Can't we have more precice one rather than total(anon+file) ?

So, I don't like this patch. Could you show total,anon,file at least ?

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
