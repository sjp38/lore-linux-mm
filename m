Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 644FF6B0087
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 01:43:43 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAM6aEgk008298
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 23:36:14 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAM6fnmm154978
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 23:41:49 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAM6fm65014662
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 23:41:49 -0700
Date: Mon, 22 Nov 2010 12:11:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/6] memcg: pass mem_cgroup to mem_cgroup_dirty_info()
Message-ID: <20101122064144.GJ12043@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
 <1289294671-6865-3-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1289294671-6865-3-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Greg Thelen <gthelen@google.com> [2010-11-09 01:24:27]:

> Pass mem_cgroup parameter through memcg_dirty_info() into
> mem_cgroup_dirty_info().  This allows for querying dirty memory
> information from a particular cgroup, rather than just the
> current task's cgroup.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
