Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF2D6B004F
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 04:13:43 -0500 (EST)
Date: Fri, 16 Jan 2009 18:13:00 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUG] memcg: panic when rmdir()
Message-Id: <20090116181300.a25f6a9c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090116172651.3e11fb0c.nishimura@mxp.nes.nec.co.jp>
References: <497025E8.8050207@cn.fujitsu.com>
	<20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
	<20090116172651.3e11fb0c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 17:26:51 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> On Fri, 16 Jan 2009 17:07:24 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, at swapoff, even while try_charge() fails, commit is executed.
> > This is bug and make refcnt of cgroup_subsys_state minus, finally.
> > 
> Nice catch!
> 
> I think this bug can explain this problem I've seen.
> Commiting on trycharge failure will add the pc to the lru
> without a corresponding charge and refcnt.
> And rmdir uncharges the pc(so we get WARNING: at kernel/res_counter.c:71)
> and decrements the refcnt(so we get BUG at kernel/cgroup.c:2517).
> 
> Even if the problem cannot be fixed by this patch, this patch is valid and needed.
> 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> I'll test it.
> 
I've tested several times, but this problem didn't happen.

Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
