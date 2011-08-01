Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 74BF790014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 02:55:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 15B083EE0BD
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:55:44 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F073F45DD70
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:55:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D7AED45DE4F
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:55:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA74D1DB8040
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:55:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9871D1DB803B
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:55:43 +0900 (JST)
Date: Mon, 1 Aug 2011 15:48:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch]mm: fix a vmscan warning
Message-Id: <20110801154827.9b56c752.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1312180877.15392.426.camel@sli10-conroe>
References: <1312180877.15392.426.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Mon, 01 Aug 2011 14:41:17 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> I get below warnning:
> BUG: using smp_processor_id() in preemptible [00000000] code: bash/746
> caller is native_sched_clock+0x37/0x6e
> Pid: 746, comm: bash Tainted: G        W   3.0.0+ #254
> Call Trace:
>  [<ffffffff813435c6>] debug_smp_processor_id+0xc2/0xdc
>  [<ffffffff8104158d>] native_sched_clock+0x37/0x6e
>  [<ffffffff81116219>] try_to_free_mem_cgroup_pages+0x7d/0x270
>  [<ffffffff8114f1f8>] mem_cgroup_force_empty+0x24b/0x27a
>  [<ffffffff8114ff21>] ? sys_close+0x38/0x138
>  [<ffffffff8114ff21>] ? sys_close+0x38/0x138
>  [<ffffffff8114f257>] mem_cgroup_force_empty_write+0x17/0x19
>  [<ffffffff810c72fb>] cgroup_file_write+0xa8/0xba
>  [<ffffffff811522d2>] vfs_write+0xb3/0x138
>  [<ffffffff8115241a>] sys_write+0x4a/0x71
>  [<ffffffff8114ffd9>] ? sys_close+0xf0/0x138
>  [<ffffffff8176deab>] system_call_fastpath+0x16/0x1b
> 
> sched_clock() can't be used with preempt enabled. And we don't
> need fast approach to get clock here, so let's use ktime API.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Tested, thanks!.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
