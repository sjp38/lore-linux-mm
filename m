Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00BC06B0099
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 21:18:31 -0500 (EST)
Date: Thu, 7 Jan 2010 11:13:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: mmotm 2010-01-06-14-34 uploaded (mm/memcontrol)
Message-Id: <20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100106171058.f1d6f393.randy.dunlap@oracle.com>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Thank you for your report.

On Wed, 6 Jan 2010 17:10:58 -0800, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> On Wed, 06 Jan 2010 14:34:36 -0800 akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2010-01-06-14-34 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> > 
> >    git://zen-kernel.org/kernel/mmotm.git
> > 
> > It contains the following patches against 2.6.33-rc3:
> 
> 
> mm/memcontrol.c: In function 'is_target_pte_for_mc':
> mm/memcontrol.c:3985: error: implicit declaration of function 'mem_cgroup_count_swap_user'
> mm/memcontrol.c: In function 'mem_cgroup_move_charge_pte_range':
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
> 
> 
> config attached.
> 
I'm sorry I missed the !CONFIG_SWAP or !CONFIG_CGROUP_MEM_RES_CTLR_SWAP case.

I'll prepare fixes.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
