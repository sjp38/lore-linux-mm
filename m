Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 19E4F6B0024
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:11:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 68A883EE0AE
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:11:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F7D145DE61
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:11:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 36C0245DE4E
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:11:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 271EE1DB803A
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:11:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E6CFF1DB802C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:11:46 +0900 (JST)
Date: Fri, 13 May 2011 19:04:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v7 11/14] memcg: create support routines for
 writeback
Message-Id: <20110513190458.ddc0fbe2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305276473-14780-12-git-send-email-gthelen@google.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
	<1305276473-14780-12-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, 13 May 2011 01:47:50 -0700
Greg Thelen <gthelen@google.com> wrote:

> Introduce memcg routines to assist in per-memcg writeback:
> 
> - mem_cgroups_over_bground_dirty_thresh() determines if any cgroups need
>   writeback because they are over their dirty memory threshold.
> 
> - should_writeback_mem_cgroup_inode() determines if an inode is
>   contributing pages to an over-limit memcg.
> 
> - mem_cgroup_writeback_done() is used periodically during writeback to
>   update memcg writeback data.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I'm okay with the bitmap..then, problem will be when set/clear wbc->for_cgroup...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
