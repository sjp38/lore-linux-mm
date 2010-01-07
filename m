Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2C0196B00A3
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 22:05:48 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0735jt4018403
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 12:05:46 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A1F1445DD70
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:05:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ADAD45DE4E
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:05:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C45B1DB803C
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:05:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 016051DB8043
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 12:05:45 +0900 (JST)
Date: Thu, 7 Jan 2010 12:02:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2010-01-06-14-34 uploaded (mm/memcontrol)
Message-Id: <20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
	<20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
	<20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 11:59:01 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Thank you for your fix.
> 
> On Thu, 7 Jan 2010 11:21:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 7 Jan 2010 11:13:19 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > Thank you for your report.
> >  
> > > > config attached.
> > > > 
> > > I'm sorry I missed the !CONFIG_SWAP or !CONFIG_CGROUP_MEM_RES_CTLR_SWAP case.
> > > 
> > > I'll prepare fixes.
> > > 
> > Nishimura-san, could you double check this ?
> > 
> It seems that this cannot fix the !CONFIG_SWAP case in my environment.
> 
> > Andrew, this is a fix onto Nishimura-san's memcg move account patch series.
> > Maybe this -> patches/memcg-move-charges-of-anonymous-swap.patch
> > 
> I think both memcg-move-charges-of-anonymous-swap.patch and
> memcg-improve-performance-in-moving-swap-charge.patch need to be fixed.
> 
> > mm/memcontrol.c: In function 'is_target_pte_for_mc':
> > mm/memcontrol.c:3985: error: implicit declaration of function 'mem_cgroup_count_swap_user'
> This derives from a bug of memcg-move-charges-of-anonymous-swap.patch,
> 
> and
> 
> > mm/memcontrol.c: In function 'mem_cgroup_move_charge_pte_range':
> > mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> > mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> > mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> this derives from that of memcg-improve-performance-in-moving-swap-charge.patch.
> 
> 
> I'm now testing my patch in some configs, and will post later.
> 
Okay, plz.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
