Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 04BDF6B00FB
	for <linux-mm@kvack.org>; Sat,  4 Jun 2011 22:46:51 -0400 (EDT)
Received: by pxi10 with SMTP id 10so2087527pxi.8
        for <linux-mm@kvack.org>; Sat, 04 Jun 2011 19:46:50 -0700 (PDT)
Date: Sun, 5 Jun 2011 11:46:41 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v8 09/12] memcg: create support routines for writeback
Message-ID: <20110605024641.GA5914@barrios-laptop>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-10-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307117538-14317-10-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, Jun 03, 2011 at 09:12:15AM -0700, Greg Thelen wrote:
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
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
