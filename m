Date: Fri, 4 Jul 2008 19:58:36 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mm 0/5] swapcgroup (v3)
Message-Id: <20080704195836.c24c6a65.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080704184033.7cac4b69.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
	<20080704184033.7cac4b69.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, IKEDA Munehiro <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jul 2008 18:40:33 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 4 Jul 2008 15:15:36 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > This is new version of swapcgroup.
> > 
> > Major changes from previous version
> > - Rebased on 2.6.26-rc5-mm3.
> >   The new -mm has been released, but these patches
> >   can be applied on 2.6.26-rc8-mm1 too with only some offset warnings.
> >   I tested these patches on 2.6.26-rc5-mm3 with some fixes about memory,
> >   and it seems to work fine.
> > - (NEW) Implemented force_empty.
> >   Currently, it simply uncharges all the charges from the group.
> > 
> > Patches
> > - [1/5] add cgroup files
> > - [2/5] add a member to swap_info_struct
> > - [3/5] implement charge and uncharge
> > - [4/5] modify vm_swap_full() 
> > - [5/5] implement force_empty
> > 
> > ToDo(in my thought. Feel free to add some others here.)
> > - need some documentation
> >   Add to memory.txt? or create a new documentation file?
> > 
> Maybe new documentation file is better. 
> 
O.K.

> > - add option to disable only this feature
> >   I'm wondering if this option is needed.
> >   memcg has already the boot option to disable it.
> >   Is there any case where memory should be accounted but swap should not?
> 
> On x86-32, area for vmalloc() is very small and array of swap_info_struct[]
> will use much amount of it. If vmalloc() area is too small, the kernel cannot
> load modules.
> 
It would be critical.
I'll add an option.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
