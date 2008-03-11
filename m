Date: Tue, 11 Mar 2008 17:32:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Message-Id: <20080311173225.937935eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47D63FBC.1010805@openvz.org>
References: <47D16004.7050204@openvz.org>
	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	<47D63FBC.1010805@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008 11:15:56 +0300
Pavel Emelyanov <xemul@openvz.org> wrote:
> > Hmm? seems strange.
> > 
> > IMO, a parent's usage is just sum of all childs'.
> > And, historically, memory overcommit is done agaist "memory usage + swap".
> > 
> > How about this ?
> >     <mem_counter_top, swap_counter_top>
> > 	<mem_counter_sub, swap_counter_sub>
> > 	<mem_counter_sub, swap_counter_sub>
> > 	<mem_counter_sub, swap_counter_sub>
> > 
> >    mem_counter_top.usage == sum of all mem_coutner_sub.usage
> >    swap_counter_sub.usage = sum of all swap_counter_sub.usage
> 
> I've misprinted in y tree, sorry.
> The correct hierarchy as I see it is
> 
thank you.

> <mem_couter_0>
>  + -- <swap_counter_0>
>  + -- <mem_counter_1>
>  |     + -- <swap_counter_1>
>  |     + -- <mem_counter_11>
>  |     |     + -- <swap_counter_11>
>  |     + -- <mem_counter_12>
>  |           + -- <swap_counter_12>
>  + -- <mem_counter_2>
>  |     + -- <swap_counter_2>
>  |     + -- <mem_counter_21>
>  |     |     + -- <swap_counter_21>
>  |     + -- <mem_counter_22>
>  |           + -- <swap_counter_22>
>  + -- <mem_counter_N>
>        + -- <swap_counter_N>
>        + -- <mem_counter_N1>
>        |     + -- <swap_counter_N1>
>        + -- <mem_counter_N2>
>              + -- <swap_counter_N2>
>
please let me confirm.

- swap_counter_X.limit can be defined independent from mem_counter_X.limit ?
- swap_conter_N1's limit and swap_counter_N's have some relationship ?

Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
