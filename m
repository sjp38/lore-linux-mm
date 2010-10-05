Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 170006B004A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 00:50:44 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o954hjp0013844
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:43:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o954ogNM1945676
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:50:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o954oge8028243
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:50:42 -0400
Date: Tue, 5 Oct 2010 10:20:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] memcg: per cgroup dirty page accounting
Message-ID: <20101005045023.GS7896@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1286175485-30643-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* Greg Thelen <gthelen@google.com> [2010-10-03 23:57:55]:

> This patch set provides the ability for each cgroup to have independent dirty
> page limits.
> 
> Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
> page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
> not be able to consume more than their designated share of dirty pages and will
> be forced to perform write-out if they cross that limit.
> 
> These patches were developed and tested on mmotm 2010-09-28-16-13.  The patches
> are based on a series proposed by Andrea Righi in Mar 2010.

Hi, Greg,

I see a problem with "    memcg: add dirty page accounting infrastructure".

The reject is

 enum mem_cgroup_write_page_stat_item {
        MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+       MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
+       MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
+       MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
 };

I don't see mem_cgroup_write_page_stat_item in memcontrol.h. Is this
based on top of Kame's cleanup.

I am working off of mmotm 28 sept 2010 16:13.


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
