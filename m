Message-Id: <47D64AD8.5020909@mxp.nes.nec.co.jp>
Date: Tue, 11 Mar 2008 18:03:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
References: <47D16004.7050204@openvz.org>	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>	<47D63FBC.1010805@openvz.org> <20080311173225.937935eb.kamezawa.hiroyu@jp.fujitsu.com> <47D6451A.7090807@openvz.org>
In-Reply-To: <47D6451A.7090807@openvz.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

> No. The mem_counter_N_limit is the limit for all the memory, that the
> Nth group consumes. This includes the RSS, page cache and swap for this
> group and all the child groups. Since RSS and page cache are accounted
> together, this limit tracks the sum of (memory + swap) values over the
> subtree started at the given group.
> 
It seems a bit confusing for me, because current memcg manages
only RSS and page cache, not swap.


>>>> IMO, a parent's usage is just sum of all childs'.
>>>> And, historically, memory overcommit is done agaist "memory usage + swap".
>>>>
>>>> How about this ?
>>>>  <mem_counter_top, swap_counter_top>
>>>> 	<mem_counter_sub, swap_counter_sub>
>>>> 	<mem_counter_sub, swap_counter_sub>
>>>> 	<mem_counter_sub, swap_counter_sub>
>>>>
>>>>    mem_counter_top.usage == sum of all mem_coutner_sub.usage
>>>>    swap_counter_sub.usage = sum of all swap_counter_sub.usage

I prefer Kamezawa-san's idea.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
