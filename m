Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F30C76B0101
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 00:53:07 -0400 (EDT)
Received: by pxi10 with SMTP id 10so2116373pxi.8
        for <linux-mm@kvack.org>; Sat, 04 Jun 2011 21:53:06 -0700 (PDT)
Date: Sun, 5 Jun 2011 13:52:55 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v8 12/12] memcg: check memcg dirty limits in page
 writeback
Message-ID: <20110605045255.GD5914@barrios-laptop>
References: <1307117797-747-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307117797-747-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, Jun 03, 2011 at 09:16:37AM -0700, Greg Thelen wrote:
> If the current process is in a non-root memcg, then
> balance_dirty_pages() will consider the memcg dirty limits as well as
> the system-wide limits.  This allows different cgroups to have distinct
> dirty limits which trigger direct and background writeback at different
> levels.
> 
> If called with a mem_cgroup, then throttle_vm_writeout() queries the
> given cgroup for its dirty memory usage limits.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
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
