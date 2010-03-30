Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B32B76B0207
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 00:08:08 -0400 (EDT)
Date: Tue, 30 Mar 2010 13:06:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH(v2) -mmotm 2/2] memcg move charge of shmem at task
 migration
Message-Id: <20100330130648.ad559645.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100330121119.fcc7d45b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
	<20100329133645.e3bde19f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330103301.b0d20f7e.nishimura@mxp.nes.nec.co.jp>
	<20100330112301.f5bb49d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330114903.476af77e.nishimura@mxp.nes.nec.co.jp>
	<20100330121119.fcc7d45b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 12:11:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 30 Mar 2010 11:49:03 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Tue, 30 Mar 2010 11:23:01 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > SHARED mapped file cache is not moved by patch [1/2] ???
> > > It sounds strange.
> > > 
> > hmm, I'm sorry I'm not so good at user applications, but is it usual to use
> > VM_SHARED file caches(!tmpfs) ?
> > And is it better for us to move them only when page_mapcount() == 1 ?
> > 
> 
> Considering shared library which has only one user, moving MAP_SHARED makes sense.
> Unfortunately, there are people who creates their own shared library just for
> their private dlopen() etc. (shared library for private use...)
> 
> So, I think moving MAP_SHARED files makes sense.
> 
Thank you for your explanations.
I'll update my patches to allow to move MAP_SHARED(but page_mapcount() == 1)
file caches, and resend.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
