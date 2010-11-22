Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2066B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 01:40:57 -0500 (EST)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAM6NaGZ005418
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 01:23:36 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAM6enln166406
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 01:40:49 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAM6emAa009421
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 23:40:49 -0700
Date: Mon, 22 Nov 2010 12:10:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/6] memcg: add mem_cgroup parameter to
 mem_cgroup_page_stat()
Message-ID: <20101122064043.GI12043@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
 <1289294671-6865-2-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1289294671-6865-2-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Greg Thelen <gthelen@google.com> [2010-11-09 01:24:26]:

> This new parameter can be used to query dirty memory usage
> from a given memcg rather than the current task's memcg.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
>

How is this useful, documenting that in the changelog would be nice. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
