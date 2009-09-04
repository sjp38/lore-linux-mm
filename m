Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B8C5A6B004F
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 02:52:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n846qScN013597
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Sep 2009 15:52:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7359B45DE5D
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 15:52:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 37FDC45DE65
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 15:52:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CB981DB8048
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 15:52:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9068E1DB803C
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 15:52:27 +0900 (JST)
Date: Fri, 4 Sep 2009 15:50:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][experimental][PATCH] coalescing charge
Message-Id: <20090904155029.ef544d5f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090904154050.25873aa5.nishimura@mxp.nes.nec.co.jp>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090903141727.ccde7e91.nishimura@mxp.nes.nec.co.jp>
	<20090904131835.ac2b8cc8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904141157.4640ec1e.nishimura@mxp.nes.nec.co.jp>
	<20090904142143.15ffcb53.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904142654.08dd159f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904154050.25873aa5.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Sep 2009 15:40:50 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 4 Sep 2009 14:26:54 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 4 Sep 2009 14:21:43 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Fri, 4 Sep 2009 14:11:57 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > > It looks basically good. I'll do some tests with all patches applied.
> > > > > > 
> > > > > thanks.
> > > > > 
> > > > it seems that these patches make rmdir stall again...
> > > > This batched charge patch seems not to be the (only) suspect, though.
> > > > 
> > > Ouch, no probelm with the latest mmotm ? I think this charge-uncharge-offload
> > > patch set doesn't use css_set()/get()...
> > > Hm, softlimit related parts ?
> > > 
> hmm, these patches(including softlimit cleanup) seems not to be guilt.
> Current(I'm using mmotm-2009-08-27-16-51) mmotm seems to be broken about memcg's rmdir.
> 
> I must admit I've not tested mmotm for several months because I have been working
> on stabilizing mainline for a long time...
> 
> > Ah, one more question. What memory.usage_in_bytes shows in that case ?
> > If not zero, charge/uncharge coalescing is guilty.
> > 
> usage_in_bytes is 0.
> I've confirmed by crash command that the mem_cgroup has extra ref counts.
> 
> I'll dig more..
> 
Ok, then, I and you see different problem...
Hmm..css refcnt leak. I'll dig, too. I hope we can catch it before sneaking
into mainline.

Thanks,
-Kame

> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
