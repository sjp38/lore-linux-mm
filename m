Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 346246B00C6
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:54:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n538mEFD032482
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Jun 2009 17:48:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 797A845DD81
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 17:48:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E48345DD7E
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 17:48:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 097281DB8038
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 17:48:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B42C11DB8047
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 17:48:13 +0900 (JST)
Date: Wed, 3 Jun 2009 17:46:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm 2/2] memcg: allow mem.limit bigger than
 memsw.limit iff unlimited
Message-Id: <20090603174641.445e3012.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090603140102.72b04b6f.nishimura@mxp.nes.nec.co.jp>
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
	<20090603115027.80f9169b.nishimura@mxp.nes.nec.co.jp>
	<20090603125228.368ecaf7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090603140102.72b04b6f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009 14:01:02 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 3 Jun 2009 12:52:28 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 3 Jun 2009 11:50:27 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > Now users cannot set mem.limit bigger than memsw.limit.
> > > This patch allows mem.limit bigger than memsw.limit iff mem.limit==unlimited.
> > > 
> > > By this, users can set memsw.limit without setting mem.limit.
> > > I think it's usefull if users want to limit memsw only.
> > > They must set mem.limit first and memsw.limit to the same value now for this purpose.
> > > They can save the first step by this patch.
> > > 
> > 
> > I don't like this. No benefits to users.
> > The user should know when they set memsw.limit they have to set memory.limit.
> > This just complicates things.
> > 
> Hmm, I think there is a user who cares only limitting logical memory(mem+swap),
> not physical memory, and wants kswapd to reclaim physical memory when congested. 
> At least, I'm a such user.
> 
> Do you disagree even if I add a file like "memory.allow_limit_memsw_only" ?
> 

How about removing memory.limit < memsw.limit condition completely ?

Thanks,
-Kame

> 
> Thanks,
> Daisuke Nishimura.
> 
> > If you want to do this, add an interface as
> >   memory.all.limit_in_bytes (or some better name)
> > and allow to set memory.limit and memory.memsw.limit _at once_.
> > 
> > But I'm not sure it's worth to try. Saving user's few steps by the kenerl patch ?
> > 
> > Thanks,
> > -Kame
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
