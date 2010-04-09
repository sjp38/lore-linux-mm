Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 99928600375
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 04:17:28 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o398HN98008482
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Apr 2010 17:17:24 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9642C45DE57
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 17:17:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 743D245DE55
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 17:17:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5675E1DB803C
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 17:17:23 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 039411DB8044
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 17:17:23 +0900 (JST)
Date: Fri, 9 Apr 2010 17:13:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 67 of 67] memcg fix prepare migration
Message-Id: <20100409171313.84f0ad66.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <545969ff079730c4d7f7.1270691510@v2.random>
References: <patchbomb.1270691443@v2.random>
	<545969ff079730c4d7f7.1270691510@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, 08 Apr 2010 03:51:50 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> If a signal is pending (task being killed by sigkill) __mem_cgroup_try_charge
> will write NULL into &mem, and css_put will oops on null pointer dereference.
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
> IP: [<ffffffff810fc6cc>] mem_cgroup_prepare_migration+0x7c/0xc0
> PGD a5d89067 PUD a5d8a067 PMD 0
> Oops: 0000 [#1] SMP
> last sysfs file: /sys/devices/platform/microcode/firmware/microcode/loading
> CPU 0
> Modules linked in: nfs lockd nfs_acl auth_rpcgss sunrpc acpi_cpufreq pcspkr sg [last unloaded: microcode]
> 
> Pid: 5299, comm: largepages Tainted: G        W  2.6.34-rc3 #3 Penryn1600SLI-110dB/To Be Filled By O.E.M.
> RIP: 0010:[<ffffffff810fc6cc>]  [<ffffffff810fc6cc>] mem_cgroup_prepare_migration+0x7c/0xc0
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Andrew, I think this patch itself should be queued up as bugfix to
exisiting code. It seems there is no dependecy to other pathces.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
