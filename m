Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA3C900001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 05:48:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9B7D03EE0C0
	for <linux-mm@kvack.org>; Fri, 13 May 2011 18:48:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7935845DE68
	for <linux-mm@kvack.org>; Fri, 13 May 2011 18:48:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BFA845DE55
	for <linux-mm@kvack.org>; Fri, 13 May 2011 18:48:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CFC9E08002
	for <linux-mm@kvack.org>; Fri, 13 May 2011 18:48:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06ED71DB8038
	for <linux-mm@kvack.org>; Fri, 13 May 2011 18:48:08 +0900 (JST)
Date: Fri, 13 May 2011 18:41:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v7 08/14] writeback: add memcg fields to
 writeback_control
Message-Id: <20110513184120.0f9444bc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305276473-14780-9-git-send-email-gthelen@google.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
	<1305276473-14780-9-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, 13 May 2011 01:47:47 -0700
Greg Thelen <gthelen@google.com> wrote:

> Add writeback_control fields to differentiate between bdi-wide and
> per-cgroup writeback.  Cgroup writeback is also able to differentiate
> between writing inodes isolated to a particular cgroup and inodes shared
> by multiple cgroups.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Personally, I want to see new flags with their usage in a patch...


> ---
>  include/linux/writeback.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index d10d133..4f5c0d2 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -47,6 +47,8 @@ struct writeback_control {
>  	unsigned for_reclaim:1;		/* Invoked from the page allocator */
>  	unsigned range_cyclic:1;	/* range_start is cyclic */
>  	unsigned more_io:1;		/* more io to be dispatched */
> +	unsigned for_cgroup:1;		/* enable cgroup writeback */
> +	unsigned shared_inodes:1;	/* write inodes spanning cgroups */
>  };


If shared_inode is really rare case...we don't need to have this shared_inodes
flag and do writeback shared_inode always.....No ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
