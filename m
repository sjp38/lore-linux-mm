Date: Mon, 7 Jul 2008 15:48:30 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mm 0/5] swapcgroup (v3)
Message-Id: <20080707154830.55c52d65.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <486F1A29.4020407@linux.vnet.ibm.com>
References: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
	<486F1A29.4020407@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Hi, Balbir-san.

On Sat, 05 Jul 2008 12:22:25 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Daisuke Nishimura wrote:
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
> 
> I think memory.txt is good. But then, we'll need to add a Table of Contents to
> it, so that swap controller documentation can be located easily.
> 
I think memory.txt is a self-closed documentation,
so I don't want to change it, honestlly.

I'll write a documentation for swap as a new file first for review.

> > - add option to disable only this feature
> >   I'm wondering if this option is needed.
> >   memcg has already the boot option to disable it.
> >   Is there any case where memory should be accounted but swap should not?
> > 
> 
> That depends on what use case you are trying to provide. Let's say I needed
> backward compatibility with 2.6.25, then I would account for memory and leave
> out swap (even though we have swap controller).
> 
O.K. I'll add option.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
