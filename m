Date: Fri, 1 Aug 2008 12:05:26 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: memo: mem+swap controller
Message-Id: <20080801120526.66b58c72.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <4668997.1217521901885.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080731220323.61e44dec.nishimura@mxp.nes.nec.co.jp>
	<20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20080731152533.dea7713a.nishimura@mxp.nes.nec.co.jp>
	<20080731155127.064aaf11.kamezawa.hiroyu@jp.fujitsu.com>
	<4668997.1217521901885.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, hugh@veritas.com, linux-mm@kvack.org, menage@google.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 1 Aug 2008 01:31:41 +0900 (JST), kamezawa.hiroyu@jp.fujitsu.com wrote:
> >> > > Following is state transition and counter handling design memo.
> >> > > This uses "3" counters to handle above conrrectly. If you have other lo
> gic,
> >> > > please teach me. (and blame me if my diagram is broken.)
> >> > > 
> >> > I don't think counting "disk swap" is good idea(global linux
> >> > dosen't count it).
> >> > Instead, I prefer counting "total swap"(that is swap entry).
> >> > 
> >> Maybe my illustration is bad. 
> >> 
> >> total_swap = swap_cache + disk_swap. Yes, I count swp_entry.
> >> But just divides it to on-memory or not.
> >> 
> >> This is just a state transition problem. When we counting only total_swap,
> >> we cannot avoid double counting of a swap_cache as memory and as swap.
> >> 
> >I agree.
> >My intention was not counting only total_swap, but counting both
> >total_swap and swap_cache.
> >
> At early stage of diaglam, I just added total_swap counter.
> (total_swap here means # of used swp_entry.)
> And failed to write diaglam ;( Maybe selection of counters was bad.
> 
> If just 2 counters are enough, it's better.
> 
I think so.

> Hmm..
> - on_memory .... # of pages used
> - disk_swap      .... # of swp_entry without SwapCache
> 
> limit_in_bytes ... limits on_memory
> total_limit    ... limits on_mempry + disk_swap.
> 
> can work ?
> 
Theoretically it works, I think.

But, one thing I'm wondering is how to distinguish
"swap_cache -> freed" and "disk_swap -> freed".

Anyway, I need more consideration.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
