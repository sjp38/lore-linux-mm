Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD3NIw5032356
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 12:23:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AEA8B45DE4F
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 12:23:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E47245DE52
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 12:23:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5037B1DB8044
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 12:23:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 03A5E1DB8041
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 12:23:18 +0900 (JST)
Date: Thu, 13 Nov 2008 12:22:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
Message-Id: <20081113122241.b77a0d14.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <491B9BB3.6010701@linux.vnet.ibm.com>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112160758.3dca0b22.akpm@linux-foundation.org>
	<20081113114908.42a6a8a7.kamezawa.hiroyu@jp.fujitsu.com>
	<491B9BB3.6010701@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Nov 2008 08:44:59 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Wed, 12 Nov 2008 16:07:58 -0800
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> >> If we do this then we can make the above "keep" behaviour non-optional,
> >> and the operator gets to choose whether or not to drop the caches
> >> before doing the rmdir.
> >>
> >> Plus, we get a new per-memcg drop_caches capability.  And it's a nicer
> >> interface, and it doesn't have the obvious races which on_rmdir has,
> >> etc.
> >>
> >> hm?
> >>
> > 
> > Balbir, how would you want to do ?
> > 
> > I planned to post shrink_uage patch later (it's easy to be implemented) regardless
> > of acceptance of this patch.
> > 
> > So, I think we should add shrink_usage now and drop this is a way to go.
> 
> I am a bit concerned about dropping stuff at will later. Ubuntu 8.10 has memory
> controller enabled and we exposed memory.force_empty interface there and now
> we've dropped it (bad on our part). I think we should have deprecated it and
> dropped it later.
> 
I *was* documented as "for debug only".

Hmm, adding force_empty again to do "shrink usage to 0" is another choice.

ok?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
