Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2A24B8D003B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 16:21:38 -0400 (EDT)
Date: Fri, 20 May 2011 13:20:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4 3/3] memcg: add memory.numastat api for numa
 statistics
Message-Id: <20110520132051.28c1bc15.akpm@linux-foundation.org>
In-Reply-To: <1305861891-26140-3-git-send-email-yinghan@google.com>
References: <1305861891-26140-1-git-send-email-yinghan@google.com>
	<1305861891-26140-3-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

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

Does it make sense to add all this code for non-NUMA kernels? 

The patch adds a kilobyte of pretty useless text to uniprocessor kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
