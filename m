Subject: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer
	from struct page)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Sep 2008 17:47:49 +0200
Message-Id: <1222098469.16700.38.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-22 at 20:12 +0900, KAMEZAWA Hiroyuki wrote:

>   - all page_cgroup struct is maintained by hash. 
>     I think we have 2 ways to handle sparse index in general
>     ...radix-tree and hash. This uses hash because radix-tree's layout is
>     affected by memory map's layout.

Could you provide further detail? That is, is this solely because our
radix tree implementation is sucky for large indexes?

If so, I did most of the work of fixing that, just need to spend a
little more time to stabalize the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
