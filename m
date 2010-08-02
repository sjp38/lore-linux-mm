Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBE95600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 14:00:54 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o72HwQwc032327
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 13:58:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o72I0sn01896650
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 14:00:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o72I0rGx007327
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 14:00:54 -0400
Date: Mon, 2 Aug 2010 23:30:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/7][memcg] virtually indexed array library.
Message-ID: <20100802180051.GX3863@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
 <20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
 <20100728124513.85bfa047.akpm@linux-foundation.org>
 <20100729093226.7b899930.kamezawa.hiroyu@jp.fujitsu.com>
 <20100729132703.2d53e8a4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100729132703.2d53e8a4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-07-29 13:27:03]:

> On Thu, 29 Jul 2010 09:32:26 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 28 Jul 2010 12:45:13 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > My gut reaction to this sort of thing is "run away in terror".  It
> > > encourages kernel developers to operate like lackadaisical userspace
> > > developers and to assume that underlying code can perform heroic and
> > > immortal feats.  But it can't.  This is the kernel and the kernel is a
> > > tough and hostile place and callers should be careful and defensive and
> > > take great efforts to minimise the strain they put upon other systems.
> > > 
> > > IOW, can we avoid doing this?
> > > 
> > 
> 
> I'll use pre-allocated pointer array in the next version. It's simple even
> if a bit slow.
> 
> ==
> struct mem_cgroup *mem_cgroups[CONFIG_MAX_MEM_CGROUPS] __read_mostly;
> #define id_to_memcg(id)		mem_cgroups[id];
> ==

Hmm.. I thought we were going to reuse css_id() and use that to get to
the cgroup. May be I am missing something.


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
