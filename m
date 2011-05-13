Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 148B96B0023
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:21:51 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 38BCE3EE0C0
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:21:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 119FD45DE5B
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:21:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC74145DE58
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:21:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DBBECEF8005
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:21:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A8011E08003
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:21:47 +0900 (JST)
Date: Fri, 13 May 2011 19:14:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v7 13/14] writeback: make background writeback
 cgroup aware
Message-Id: <20110513191459.e7b2ad0b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305276473-14780-14-git-send-email-gthelen@google.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
	<1305276473-14780-14-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, 13 May 2011 01:47:52 -0700
Greg Thelen <gthelen@google.com> wrote:

> When the system is under background dirty memory threshold but a cgroup
> is over its background dirty memory threshold, then only writeback
> inodes associated with the over-limit cgroup(s).
> 
> In addition to checking if the system dirty memory usage is over the
> system background threshold, over_bground_thresh() also checks if any
> cgroups are over their respective background dirty memory thresholds.
> The writeback_control.for_cgroup field is set to distinguish between a
> system and memcg overage.
> 
> If performing cgroup writeback, move_expired_inodes() skips inodes that
> do not contribute dirty pages to the cgroup being written back.
> 
> After writing some pages, wb_writeback() will call
> mem_cgroup_writeback_done() to update the set of over-bg-limits memcg.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Seems ok to me, at least..
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
