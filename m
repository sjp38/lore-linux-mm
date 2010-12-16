Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 641C76B00AE
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 20:19:18 -0500 (EST)
Date: Thu, 16 Dec 2010 10:10:53 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: Transparent Hugepage Support #33
Message-Id: <20101216101053.05cb1516.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101215051540.GP5638@random.random>
	<20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 16 Dec 2010 09:54:08 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 15 Dec 2010 06:15:40 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > Some of some relevant user of the project:
> > 
> > KVM Virtualization
> > GCC (kernel build included, requires a few liner patch to enable)
> > JVM
> > VMware Workstation
> > HPC
> > 
> > It would be great if it could go in -mm.
> 
> Things should be done in memory cgroup is
>  
>  - make accounting correct (RSS count will be broken)
>  - make move_charge() to work
>    (at rmdir(), this is now broken. It seems move-charge-at-task-move to work)
> 
Yes.
I think we should add mem_cgroup_split_hugepage_commit() and add PageTransHuge()
check in mem_cgroup_move_parent() as done in RHEL6 kernel.
As for move-charge-at-task-move, it will work because walk_pmd_range() splits
THP pages(it would be better to change move-charge not to split THP pages, but
it's not so urgent IMHO).

> Do you have known other viewpoints ?
Not yet, but I'll test and check.

> I'll look into when -mm is shipped.
> 
me too :)


Thanks,
Daisuke Nihimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
