Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 107A36B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 00:00:44 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF50gOM025212
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 14:00:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AECA545DE51
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:00:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D58745DE4E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:00:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AA451DB8061
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:00:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5030EE1800B
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:00:41 +0900 (JST)
Date: Tue, 15 Dec 2009 13:57:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v4.2
Message-Id: <20091215135738.93e49d56.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091215133546.6872fc4f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
	<20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com>
	<20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
	<20091118095824.076c211f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911171725050.13760@chino.kir.corp.google.com>
	<20091214171632.0b34d833.akpm@linux-foundation.org>
	<20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0912142025090.29243@chino.kir.corp.google.com>
	<20091215133546.6872fc4f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009 13:35:46 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 14 Dec 2009 20:30:37 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> > >     2 ideas which I can think of now are..
> > >     1) add sysctl_oom_calc_on_committed_memory 
> > >        If this is set, use vm-size instead of rss.
> > > 
> > 
> > I would agree only if the oom killer used total_vm as a the default, it is 
> > long-standing and allows for the aforementioned capability that you lose 
> > with rss.  I have no problem with the added sysctl to use rss as the 
> > baseline when enabled.
> > 
> I'll prepare a patch for adds
> 
>   sysctl_oom_kill_based_on_rss (default=0)
> 
Hmm..

But for usual desktop users, using rss as default,as memory-eater-should-die.
sounds reasoable to me.
Hmm...maybe some automatic detection logic is required.

As my 1st version shows, 

   CONSTRAINT_CPUSET -> use vm_size
   CONSTRAINT_LOWMEM -> use lowmem_rss
   CONSTRAINT_NONE   -> use rss
seems like a landing point for all stake holders. No ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
