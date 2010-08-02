Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 524F2600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:46:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o72Nnp1A009004
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 08:49:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 444B545DE4F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:49:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2150445DE4E
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:49:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E41A51DB804F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:49:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DD611DB8044
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:49:50 +0900 (JST)
Date: Tue, 3 Aug 2010 08:45:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/7][memcg] virtually indexed array library.
Message-Id: <20100803084500.8bf99ff2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100802180051.GX3863@balbir.in.ibm.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728124513.85bfa047.akpm@linux-foundation.org>
	<20100729093226.7b899930.kamezawa.hiroyu@jp.fujitsu.com>
	<20100729132703.2d53e8a4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802180051.GX3863@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2010 23:30:51 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-07-29 13:27:03]:
> 
> > On Thu, 29 Jul 2010 09:32:26 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Wed, 28 Jul 2010 12:45:13 -0700
> > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > > My gut reaction to this sort of thing is "run away in terror".  It
> > > > encourages kernel developers to operate like lackadaisical userspace
> > > > developers and to assume that underlying code can perform heroic and
> > > > immortal feats.  But it can't.  This is the kernel and the kernel is a
> > > > tough and hostile place and callers should be careful and defensive and
> > > > take great efforts to minimise the strain they put upon other systems.
> > > > 
> > > > IOW, can we avoid doing this?
> > > > 
> > > 
> > 
> > I'll use pre-allocated pointer array in the next version. It's simple even
> > if a bit slow.
> > 
> > ==
> > struct mem_cgroup *mem_cgroups[CONFIG_MAX_MEM_CGROUPS] __read_mostly;
> > #define id_to_memcg(id)		mem_cgroups[id];
> > ==
> 
> Hmm.. I thought we were going to reuse css_id() and use that to get to
> the cgroup. May be I am missing something.
> 
?
lookup_css_id() requires multi-level table lookup because of radix-tree.
And compiler can't generate an optimized code. linear table lookup is quick.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
