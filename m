Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 884D28D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 15:41:00 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 5/6] memcg: simplify mem_cgroup_dirty_info()
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-6-git-send-email-gthelen@google.com>
	<20101112082150.GG9131@cmpxchg.org>
Date: Fri, 12 Nov 2010 12:40:42 -0800
Message-ID: <xr93hbfmxol1.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Tue, Nov 09, 2010 at 01:24:30AM -0800, Greg Thelen wrote:
>> Because mem_cgroup_page_stat() no longer returns negative numbers
>> to indicate failure, mem_cgroup_dirty_info() does not need to check
>> for such failures.
>
> This is simply not true at this point in time.  Patch ordering is not
> optional.

Thanks.  Patch order will be corrected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
