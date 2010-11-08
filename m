Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 27DFC6B0085
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 04:51:03 -0500 (EST)
Date: Mon, 8 Nov 2010 10:50:55 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUGFIX][PATCH] fix wrong VM_BUG_ON() in try_charge()'s
 mm->owner check
Message-ID: <20101108095040.GK23393@cmpxchg.org>
References: <AANLkTikCUdpx-jGhKdzueML39CnExumk1i_X_OZJihE2@mail.gmail.com>
 <alpine.LSU.2.00.1011041016520.19411@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1011041016520.19411@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, Nov 04, 2010 at 10:31:58AM -0700, Hugh Dickins wrote:
> On Wed, 3 Nov 2010, Hiroyuki Kamezawa wrote:
> > I'm sorry for attached file, I have to use unusual mailer this time.
> > This is a fix for wrong VM_BUG_ON() for mm/memcontol.c
> 
> Thanks, Kame, that's good: I've inlined it below with Balbir's Review,
> my Ack, and a Cc: stable@kernel.org.
> 
> Hugh
> 
> 
> [PATCH] memcg: fix wrong VM_BUG_ON() in try_charge()'s mm->owner check
> 
> At __mem_cgroup_try_charge(), VM_BUG_ON(!mm->owner) is checked.
> But as commented in mem_cgroup_from_task(), mm->owner can be NULL in some racy
> case. This check of VM_BUG_ON() is bad.
> 
> A possible story to hit this is at swapoff()->try_to_unuse(). It passes
> mm_struct to mem_cgroup_try_charge_swapin() while mm->owner is NULL. If we
> can't get proper mem_cgroup from swap_cgroup information, mm->owner is used
> as charge target and we see NULL.
> 
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> Cc: stable@kernel.org

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
