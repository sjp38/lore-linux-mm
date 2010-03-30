Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 84C976B020B
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 23:15:05 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U3F10D001098
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Mar 2010 12:15:01 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 25B8C45DE55
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:15:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E5C2145DE52
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:15:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BF466E18009
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:15:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 74E76E18004
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:15:00 +0900 (JST)
Date: Tue, 30 Mar 2010 12:11:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH(v2) -mmotm 2/2] memcg move charge of shmem at task
 migration
Message-Id: <20100330121119.fcc7d45b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100330114903.476af77e.nishimura@mxp.nes.nec.co.jp>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
	<20100329133645.e3bde19f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330103301.b0d20f7e.nishimura@mxp.nes.nec.co.jp>
	<20100330112301.f5bb49d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330114903.476af77e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 11:49:03 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 30 Mar 2010 11:23:01 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > SHARED mapped file cache is not moved by patch [1/2] ???
> > It sounds strange.
> > 
> hmm, I'm sorry I'm not so good at user applications, but is it usual to use
> VM_SHARED file caches(!tmpfs) ?
> And is it better for us to move them only when page_mapcount() == 1 ?
> 

Considering shared library which has only one user, moving MAP_SHARED makes sense.
Unfortunately, there are people who creates their own shared library just for
their private dlopen() etc. (shared library for private use...)

So, I think moving MAP_SHARED files makes sense.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
