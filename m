Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 66EB36B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 03:02:59 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n597TjHI012514
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Jun 2009 16:29:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C86D145DD72
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:29:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EB1B45DE4F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:29:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 85CAE1DB8038
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:29:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D6E51DB8043
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:29:44 +0900 (JST)
Date: Tue, 9 Jun 2009 16:28:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] vmscan: handle may_swap more strictly (Re: [PATCH
 mmotm] vmscan: fix may_swap handling for memcg)
Message-Id: <20090609162813.4bd1c1f2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090609161330.fcd5facb.nishimura@mxp.nes.nec.co.jp>
References: <20090608121848.4370.A69D9226@jp.fujitsu.com>
	<20090608153916.3ccaeb9a.nishimura@mxp.nes.nec.co.jp>
	<20090608154634.437F.A69D9226@jp.fujitsu.com>
	<20090608165457.fa8d17e6.nishimura@mxp.nes.nec.co.jp>
	<20090609161330.fcd5facb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jun 2009 16:13:30 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > > and, too many recliaming pages is not only memcg issue. I don't think this
> > > patch provide generic solution.
> > > 
> > Ah, you're right. It's not only memcg issue.
> > 
> How about this one ?
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Commit 2e2e425989080cc534fc0fca154cae515f971cf5 ("vmscan,memcg: reintroduce
> sc->may_swap) add may_swap flag and handle it at get_scan_ratio().
> 
> But the result of get_scan_ratio() is ignored when priority == 0,
> so anon lru is scanned even if may_swap == 0 or nr_swap_pages == 0.
> IMHO, this is not an expected behavior.
> 
> As for memcg especially, because of this behavior many and many pages are
> swapped-out just in vain when oom is invoked by mem+swap limit.
> 
> This patch is for handling may_swap flag more strictly.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
