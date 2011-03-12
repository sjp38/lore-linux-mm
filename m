Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DDC388D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 20:11:05 -0500 (EST)
Date: Fri, 11 Mar 2011 17:10:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-Id: <20110311171006.ec0d9c37.akpm@linux-foundation.org>
In-Reply-To: <1299869011-26152-1-git-send-email-gthelen@google.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Fri, 11 Mar 2011 10:43:22 -0800
Greg Thelen <gthelen@google.com> wrote:

>
> ...
> 
> This patch set provides the ability for each cgroup to have independent dirty
> page limits.

Here, it would be helpful to describe the current kernel behaviour. 
And to explain what is wrong with it and why the patch set improves
things!

> 
> ...
>
> Known shortcomings (see the patch 1/9 update to Documentation/cgroups/memory.txt
> for more details):
> - When a cgroup dirty limit is exceeded, then bdi writeback is employed to
>   writeback dirty inodes.  Bdi writeback considers inodes from any cgroup, not
>   just inodes contributing dirty pages to the cgroup exceeding its limit.  

This is a pretty large shortcoming, I suspect.  Will it be addressed?

There's a risk that a poorly (or maliciously) configured memcg could
have a pretty large affect upon overall system behaviour.  Would
elevated premissions be needed to do this?

We could just crawl the memcg's page LRU and bring things under control
that way, couldn't we?  That would fix it.  What were the reasons for
not doing this?

> - A cgroup may exceed its dirty limit if the memory is dirtied by a process in a
>   different memcg.

Please describe this scenario in (a lot) more detail?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
