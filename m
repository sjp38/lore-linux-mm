Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 34D4B6B004F
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 02:49:08 -0400 (EDT)
Date: Fri, 4 Sep 2009 15:40:50 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [mmotm][experimental][PATCH] coalescing charge
Message-Id: <20090904154050.25873aa5.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090904142654.08dd159f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090903141727.ccde7e91.nishimura@mxp.nes.nec.co.jp>
	<20090904131835.ac2b8cc8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904141157.4640ec1e.nishimura@mxp.nes.nec.co.jp>
	<20090904142143.15ffcb53.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904142654.08dd159f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Sep 2009 14:26:54 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 4 Sep 2009 14:21:43 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Fri, 4 Sep 2009 14:11:57 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > It looks basically good. I'll do some tests with all patches applied.
> > > > > 
> > > > thanks.
> > > > 
> > > it seems that these patches make rmdir stall again...
> > > This batched charge patch seems not to be the (only) suspect, though.
> > > 
> > Ouch, no probelm with the latest mmotm ? I think this charge-uncharge-offload
> > patch set doesn't use css_set()/get()...
> > Hm, softlimit related parts ?
> > 
hmm, these patches(including softlimit cleanup) seems not to be guilt.
Current(I'm using mmotm-2009-08-27-16-51) mmotm seems to be broken about memcg's rmdir.

I must admit I've not tested mmotm for several months because I have been working
on stabilizing mainline for a long time...

> Ah, one more question. What memory.usage_in_bytes shows in that case ?
> If not zero, charge/uncharge coalescing is guilty.
> 
usage_in_bytes is 0.
I've confirmed by crash command that the mem_cgroup has extra ref counts.

I'll dig more..


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
