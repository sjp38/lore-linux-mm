Date: Fri, 1 Aug 2008 13:02:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: memo: mem+swap controller
Message-Id: <20080801130203.b220f3a1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <489282C7.2020500@linux.vnet.ibm.com>
References: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20080731152533.dea7713a.nishimura@mxp.nes.nec.co.jp>
	<489282C7.2020500@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 01 Aug 2008 08:58:07 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Daisuke Nishimura wrote:
> > Hi, Kamezawa-san.
> > 
> > On Thu, 31 Jul 2008 10:15:33 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> Hi, mem+swap controller is suggested by Hugh Dickins and I think it's a great
> >> idea. Its concept is having 2 limits. (please point out if I misunderstand.)
> >>
> >>  - memory.limit_in_bytes       .... limit memory usage.
> >>  - memory.total_limit_in_bytes .... limit memory+swap usage.
> >>
> > When I've considered more, I wonder how we can accomplish
> > "do not use swap in this group".
> > 
> 
> It's easy use the memrlimit controller and set virtual address limit <=
> memory.limit_in_bytes. I use that to make sure I never swap out.
> 
I don't think it works under memory pressure *outside* of the group,
that is, global memory reclaim.
(I think "limit_in_bytes == total_limit_in_bytes" also works *inside* memory 
pressure.)

> > Setting "limit_in_bytes == total_limit_in_bytes" doesn't meet it, I think.
> > "limit_in_bytes = total_limit_in_bytes = 1G" cannot
> > avoid "memory.usage = 700M swap.usage = 300M" under memory pressure
> > outside of the group(and I think this behavior is the diffrence
> > of "memory controller + swap controller" and "mem+swap controller").
> > 
> > I think total_limit_in_bytes and swappiness(or some flag to indicate
> > "do not swap out"?) for each group would make more sense.
> 
> I do intend to add the swappiness feature soon for control groups.
> 
How does it work?
Does it affect global page reclaim?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
