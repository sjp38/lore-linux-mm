Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B2D5290014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 02:44:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CF5FA3EE0C1
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:44:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B5D4145DE4E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:44:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F44E45DD70
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:44:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 92F231DB803B
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:44:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 601451DB802F
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 15:44:14 +0900 (JST)
Date: Mon, 1 Aug 2011 15:37:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch]mm: fix a memcg warning
Message-Id: <20110801153700.e6f1c9b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1312180878.15392.427.camel@sli10-conroe>
References: <1312180878.15392.427.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Mon, 01 Aug 2011 14:41:18 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> I get below warning:
> BUG: using smp_processor_id() in preemptible [00000000] code: bash/739
> caller is drain_local_stock+0x1a/0x55
> Pid: 739, comm: bash Tainted: G        W   3.0.0+ #255
> Call Trace:
>  [<ffffffff813435c6>] debug_smp_processor_id+0xc2/0xdc
>  [<ffffffff8114ae9b>] drain_local_stock+0x1a/0x55
>  [<ffffffff8114b076>] drain_all_stock+0x98/0x13a
>  [<ffffffff8114f04c>] mem_cgroup_force_empty+0xa3/0x27a
>  [<ffffffff8114ff1d>] ? sys_close+0x38/0x138
>  [<ffffffff811a7631>] ? environ_read+0x1d/0x159
>  [<ffffffff8114f253>] mem_cgroup_force_empty_write+0x17/0x19
>  [<ffffffff810c72fb>] cgroup_file_write+0xa8/0xba
>  [<ffffffff811522ce>] vfs_write+0xb3/0x138
>  [<ffffffff81152416>] sys_write+0x4a/0x71
>  [<ffffffff8114ffd5>] ? sys_close+0xf0/0x138
>  [<ffffffff8176deab>] system_call_fastpath+0x16/0x1b
> 
> drain_local_stock() should be run with preempt disabled.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 

Thanks,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

IIUC, I myself didn't see this warning when I wrote codes.
Do I need to set some CONFIG ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
