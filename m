Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E6BA06B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 02:58:44 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V6xcZS016000
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 15:59:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5ED3A45DD7B
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:59:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FB5E45DD78
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:59:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CE401DB803F
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:59:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DEBA61DB803C
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:59:37 +0900 (JST)
Date: Tue, 31 Mar 2009 15:58:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-Id: <20090331155810.85bfb987.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090331064901.GK16497@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328181100.GB26686@balbir.in.ibm.com>
	<20090328182747.GA8339@balbir.in.ibm.com>
	<20090331085538.2aaa5e2b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331050055.GF16497@balbir.in.ibm.com>
	<20090331140502.813993cc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331061010.GJ16497@balbir.in.ibm.com>
	<20090331152843.e1db942b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331064901.GK16497@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 12:19:02 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > >  At some point, memcg soft limit reclaim
> > > hits A and reclaims memory from it, allowing B to run without any
> > > problems. I am talking about the state at the end of the experiment.
> > > 
> > Considering LRU rotation (ACTIVE->INACTIVE), pages in group B never goes back
> > to ACTIVE list and can be the first candidates for swap-out via kswapd.
> > 
> > Hmm....kswapd doesn't work at all ?
> > 
> > (or 1700MB was too much.)
> >
> 
> No 1700MB is not too much, since we reclaim from A towards the end
> when ld runs. I need to investigate more and look at the watermarks,
> may be soft limit reclaim reclaims enough and/or the watermarks are
> not very high. I use fake NUMA nodes as well.
>  
When talking about XXMB of swap, +100MB is much ;)

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
