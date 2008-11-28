Date: Fri, 28 Nov 2008 21:49:21 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH -mmotm 0/2] misc patches for memory cgroup
 hierarchy
Message-Id: <20081128214921.86c30347.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081128194938.508a3b22.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
	<20081128194938.508a3b22.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Nov 2008 19:49:38 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 28 Nov 2008 18:02:52 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > I'm writing some patches for memory cgroup hierarchy.
> > 
> > I think KAMEZAWA-san's cgroup-id patches are the most important pathes now,
> > but I post these patches as RFC before going further.
> > 
> Don't wait me ;) I'll rebase mine.
> 
I see :)

> 
> > Patch descriptions:
> > - [1/2] take account of memsw
> >     mem_cgroup_hierarchical_reclaim checks only mem->res now.
> >     It should also check mem->memsw when do_swap_account.
> > - [2/2] avoid oom
> >     In previous implementation, mem_cgroup_try_charge checked the return
> >     value of mem_cgroup_try_to_free_pages, and just retried if some pages
> >     had been reclaimed.
> >     But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
> >     only checks whether the usage is less than the limit.
> >     I see oom easily in some tests which didn't cause oom before.
> > 
> > Both patches are for memory-cgroup-hierarchical-reclaim-v4 patch series.
> > 
> > My current plan for memory cgroup hierarchy:
> > - If hierarchy is enabled, limit of child should not exceed that of parent.
>  limit of a child or
>  limit of sum of children ?
> 
I'm sorry for my poor explanation.
I meant *max* of limits of children.

I think setting limit like

	group A (limit=1G)
		group A0 (limit=500M)
		group A1 (limit=800M)

is not wrong itself.


Thanks,
Daisuke Nishimura.

> > - Change other calls for mem_cgroup_try_to_free_page() to
> >   mem_cgroup_hierarchical_reclaim() if possible.
> > 
>  maybe makes sense.
> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
