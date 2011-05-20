Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C6F786B0012
	for <linux-mm@kvack.org>; Fri, 20 May 2011 00:23:45 -0400 (EDT)
Date: Fri, 20 May 2011 13:20:46 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH V4 3/3] memcg: add memory.numastat api for numa
 statistics
Message-Id: <20110520132046.bbfd9aa0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1305861891-26140-3-git-send-email-yinghan@google.com>
References: <1305861891-26140-1-git-send-email-yinghan@google.com>
	<1305861891-26140-3-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Thu, 19 May 2011 20:24:51 -0700
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
> total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> 
> And we have per-node:
> total = file + anon + unevictable
> 
> $ cat /dev/cgroup/memory/memory.numa_stat
> total=250020 N0=87620 N1=52367 N2=45298 N3=64735
> file=225232 N0=83402 N1=46160 N2=40522 N3=55148
> anon=21053 N0=3424 N1=6207 N2=4776 N3=6646
> unevictable=3735 N0=794 N1=0 N2=0 N3=2941
> 
> change v4..v3:
> 1. add per-node "unevictable" value.
> 2. change the functions to be static.
> 
> change v3..v2:
> 1. calculate the "total" based on the per-memcg lru size instead of rss+cache.
> this makes the "total" value to be consistant w/ the per-node values follows
> after.
> 
> change v2..v1:
> 1. add also the file and anon pages on per-node distribution.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
