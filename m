Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DCF736B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 00:12:44 -0400 (EDT)
Date: Mon, 29 Jun 2009 13:10:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: cgroup fix rmdir hang
Message-Id: <20090629131037.bdd56fb0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090626150052.362e1819.nishimura@mxp.nes.nec.co.jp>
References: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090626141020.849a081e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090626150052.362e1819.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jun 2009 15:00:52 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> On Fri, 26 Jun 2009 14:10:20 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > I hope this will be a final bullet..
> > I myself think this one is enough simple and good.
> I think so too :)
> Using test_and_clear_bit() and checking CGRP_WAIT_ON_RMDIR before sleeping
> would be a good idea to make the patch simple.
> 
> > I'm sorry that we need test again.
> No problem.
> I'll test this one this weekend.
> 
It has survived my test(rmdir under memory pressure) this weekend.
Please feel free to add my Tested-by.

	Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
