From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <22188426.1222099453986.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 23 Sep 2008 01:04:13 +0900 (JST)
Subject: Re: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer from struct page)
In-Reply-To: <1222098469.16700.38.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1222098469.16700.38.camel@lappy.programming.kicks-ass.net>
 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>On Mon, 2008-09-22 at 20:12 +0900, KAMEZAWA Hiroyuki wrote:
>
>>   - all page_cgroup struct is maintained by hash. 
>>     I think we have 2 ways to handle sparse index in general
>>     ...radix-tree and hash. This uses hash because radix-tree's layout is
>>     affected by memory map's layout.
>
>Could you provide further detail? That is, is this solely because our
>radix tree implementation is sucky for large indexes?
>
no, sparse-large index.

>If so, I did most of the work of fixing that, just need to spend a
>little more time to stabalize the code.
>

IIUC, radix tree's height is determined by how sparse the space is.

In big servers, each node's memory is tend to be aligned to some aligned
address. like (following is an extreme example)

 256M.....node 0     equips 4GB mem =32section
 <very big hole>
 256T  .... node 1   equips 4GB mem =32section
 <very big hole>
 512T  .... node 2   equips 4GB mem =32section
 <very big hole>
 .....

Then, steps to reach entries is tend to be larger than hash.
I'm sorry if I misunderstood.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
