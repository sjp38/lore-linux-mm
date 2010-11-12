Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1576B00BD
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 03:22:06 -0500 (EST)
Date: Fri, 12 Nov 2010 09:21:50 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] memcg: simplify mem_cgroup_dirty_info()
Message-ID: <20101112082150.GG9131@cmpxchg.org>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
 <1289294671-6865-6-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289294671-6865-6-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 01:24:30AM -0800, Greg Thelen wrote:
> Because mem_cgroup_page_stat() no longer returns negative numbers
> to indicate failure, mem_cgroup_dirty_info() does not need to check
> for such failures.

This is simply not true at this point in time.  Patch ordering is not
optional.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
