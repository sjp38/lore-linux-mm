Subject: Re: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer
	from struct page)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <22188426.1222099453986.kamezawa.hiroyu@jp.fujitsu.com>
References: <1222098469.16700.38.camel@lappy.programming.kicks-ass.net>
	 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
	 <22188426.1222099453986.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Sep 2008 18:06:31 +0200
Message-Id: <1222099591.16700.39.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-23 at 01:04 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
> >On Mon, 2008-09-22 at 20:12 +0900, KAMEZAWA Hiroyuki wrote:
> >
> >>   - all page_cgroup struct is maintained by hash. 
> >>     I think we have 2 ways to handle sparse index in general
> >>     ...radix-tree and hash. This uses hash because radix-tree's layout is
> >>     affected by memory map's layout.
> >
> >Could you provide further detail? That is, is this solely because our
> >radix tree implementation is sucky for large indexes?
> >
> no, sparse-large index.
> 
> >If so, I did most of the work of fixing that, just need to spend a
> >little more time to stabalize the code.
> >
> 
> IIUC, radix tree's height is determined by how sparse the space is.

Right, so Yes. Its that which I fixed.

> Then, steps to reach entries is tend to be larger than hash.
> I'm sorry if I misunderstood.

No problems,. I'll try and brush up that radix tree code and post
sometime soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
