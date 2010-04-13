Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C437F6B0203
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 00:31:55 -0400 (EDT)
Date: Mon, 12 Apr 2010 21:29:13 -0400
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 67 of 67] memcg fix prepare migration
Message-Id: <20100412212913.55be5ce5.akpm@linux-foundation.org>
In-Reply-To: <20100408125722.2a11257d.nishimura@mxp.nes.nec.co.jp>
References: <patchbomb.1270691443@v2.random>
	<545969ff079730c4d7f7.1270691510@v2.random>
	<20100408125722.2a11257d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 12:57:22 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 08 Apr 2010 03:51:50 +0200, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > If a signal is pending (task being killed by sigkill) __mem_cgroup_try_charge
> > will write NULL into &mem, and css_put will oops on null pointer dereference.
> > 
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
> > IP: [<ffffffff810fc6cc>] mem_cgroup_prepare_migration+0x7c/0xc0
> > PGD a5d89067 PUD a5d8a067 PMD 0
> > Oops: 0000 [#1] SMP
> > last sysfs file: /sys/devices/platform/microcode/firmware/microcode/loading
> > CPU 0
> > Modules linked in: nfs lockd nfs_acl auth_rpcgss sunrpc acpi_cpufreq pcspkr sg [last unloaded: microcode]
> > 
> > Pid: 5299, comm: largepages Tainted: G        W  2.6.34-rc3 #3 Penryn1600SLI-110dB/To Be Filled By O.E.M.
> > RIP: 0010:[<ffffffff810fc6cc>]  [<ffffffff810fc6cc>] mem_cgroup_prepare_migration+0x7c/0xc0
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Nice catch !
> 
> But I think this fix should be forwarded to 34-rc and stable. They all have
> the same problem if the "current" which is doing the page migration is being
> oom-killed.

OK.  I added the cc:stable.  The patch gets a trivial reject vs 2.6.33,
but they'll work it out ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
