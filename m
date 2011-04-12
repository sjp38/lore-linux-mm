Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 356DF900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:55:09 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p3CNt5fO000812
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:55:06 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by kpbe15.cbf.corp.google.com with ESMTP id p3CNsmfD020910
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:55:04 -0700
Received: by pzk2 with SMTP id 2so62810pzk.9
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:55:04 -0700 (PDT)
Date: Tue, 12 Apr 2011 16:55:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: per-node vmstat show proper vmstats
In-Reply-To: <20110411201015.F5BC.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104121654340.10966@chino.kir.corp.google.com>
References: <20110411201015.F5BC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, Wu Fengguang <fengguang.wu@intel.com>

On Mon, 11 Apr 2011, KOSAKI Motohiro wrote:

> commit 2ac390370a (writeback: add /sys/devices/system/node/<node>/vmstat)
> added vmstat entry. But strangely it only show nr_written and nr_dirtied.
> 
>         # cat /sys/devices/system/node/node20/vmstat
>         nr_written 0
>         nr_dirtied 0
> 
> Of cource, It's no adequate. With this patch, the vmstat show
> all vm stastics as /proc/vmstat.
> 
>         # cat /sys/devices/system/node/node0/vmstat
> 	nr_free_pages 899224
> 	nr_inactive_anon 201
> 	nr_active_anon 17380
> 	nr_inactive_file 31572
> 	nr_active_file 28277
> 	nr_unevictable 0
> 	nr_mlock 0
> 	nr_anon_pages 17321
> 	nr_mapped 8640
> 	nr_file_pages 60107
> 	nr_dirty 33
> 	nr_writeback 0
> 	nr_slab_reclaimable 6850
> 	nr_slab_unreclaimable 7604
> 	nr_page_table_pages 3105
> 	nr_kernel_stack 175
> 	nr_unstable 0
> 	nr_bounce 0
> 	nr_vmscan_write 0
> 	nr_writeback_temp 0
> 	nr_isolated_anon 0
> 	nr_isolated_file 0
> 	nr_shmem 260
> 	nr_dirtied 1050
> 	nr_written 938
> 	numa_hit 962872
> 	numa_miss 0
> 	numa_foreign 0
> 	numa_interleave 8617
> 	numa_local 962872
> 	numa_other 0
> 	nr_anon_transparent_hugepages 0
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Michael Rubin <mrubin@google.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>

This is very useful for cpuset users.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
