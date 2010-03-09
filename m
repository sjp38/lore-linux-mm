Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 54A766B0095
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 19:24:37 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o290OZ88032413
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Mar 2010 09:24:35 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E0F1145DE53
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 09:24:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B5DD545DE4E
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 09:24:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D871E38003
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 09:24:34 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3840C1DB8043
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 09:24:34 +0900 (JST)
Date: Tue, 9 Mar 2010 09:20:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure
Message-Id: <20100309092054.b18a4ff2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100309091845.d38b43ff.nishimura@mxp.nes.nec.co.jp>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
	<1267995474-9117-4-git-send-email-arighi@develer.com>
	<20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
	<20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309091845.d38b43ff.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010 09:18:45 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Mon, 8 Mar 2010 17:31:00 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 8 Mar 2010 17:07:11 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > Hmm...accepatable ? (sounds it's in error-range)
> > 
> > BTW, why local_irq_disable() ? 
> > local_irq_save()/restore() isn't better ?
> > 
> I don't have any strong reason. All of lock_page_cgroup() is *now* called w/o irq disabled,
> so I used just disable()/enable() instead of save()/restore().

My point is, this will be used under treelock soon.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
