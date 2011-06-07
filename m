Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBE76B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 03:53:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 894663EE0C0
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:53:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 66A1845DED1
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:53:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 391E445DEDA
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:53:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 21EE6E78009
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:53:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D9A22E78003
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:53:28 +0900 (JST)
Date: Tue, 7 Jun 2011 16:46:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 09/12] memcg: create support routines for writeback
Message-Id: <20110607164616.d31b0649.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1307117538-14317-10-git-send-email-gthelen@google.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
	<1307117538-14317-10-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri,  3 Jun 2011 09:12:15 -0700
Greg Thelen <gthelen@google.com> wrote:

> Introduce memcg routines to assist in per-memcg writeback:
> 
> - mem_cgroups_over_bground_dirty_thresh() determines if any cgroups need
>   writeback because they are over their dirty memory threshold.
> 
> - should_writeback_mem_cgroup_inode() determines if an inode is
>   contributing pages to an over-limit memcg.  A new writeback_control
>   field determines if shared inodes should be written back.
> 
> - mem_cgroup_writeback_done() is used periodically during writeback to
>   update memcg writeback data.
> 
> These routines make use of a new over_bground_dirty_thresh bitmap that
> indicates which mem_cgroup are over their respective dirty background
> threshold.  As this bitmap is indexed by css_id, the largest possible
> css_id value is needed to create the bitmap.  So move the definition of
> CSS_ID_MAX from cgroup.c to cgroup.h.  This allows users of css_id() to
> know the largest possible css_id value.  This knowledge can be used to
> build such per-cgroup bitmaps.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
