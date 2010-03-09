Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C840A6B009B
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 20:07:13 -0500 (EST)
Date: Tue, 9 Mar 2010 09:52:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure
Message-Id: <20100309095219.2f756ae1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100309092054.b18a4ff2.kamezawa.hiroyu@jp.fujitsu.com>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
	<1267995474-9117-4-git-send-email-arighi@develer.com>
	<20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
	<20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309091845.d38b43ff.nishimura@mxp.nes.nec.co.jp>
	<20100309092054.b18a4ff2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010 09:20:54 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 9 Mar 2010 09:18:45 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Mon, 8 Mar 2010 17:31:00 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Mon, 8 Mar 2010 17:07:11 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > Hmm...accepatable ? (sounds it's in error-range)
> > > 
> > > BTW, why local_irq_disable() ? 
> > > local_irq_save()/restore() isn't better ?
> > > 
> > I don't have any strong reason. All of lock_page_cgroup() is *now* called w/o irq disabled,
> > so I used just disable()/enable() instead of save()/restore().
> 
> My point is, this will be used under treelock soon.
> 
I agree.

I'll update the patch using save()/restore(), and repost later.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
