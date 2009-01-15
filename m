Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7737E6B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 00:57:01 -0500 (EST)
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id n0F67nGZ181468
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 17:07:49 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0F5nOSe306420
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:49:25 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0F5nNm3005675
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:49:24 +1100
Date: Thu, 15 Jan 2009 11:19:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
	obsolete
Message-ID: <20090115054903.GA30358@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp> <20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp> <7602a77a9fc6b1e8757468048fde749a.squirrel@webmail-b.css.fujitsu.com> <20090115100330.37d89d3d.nishimura@mxp.nes.nec.co.jp> <20090115110044.3a863af8.kamezawa.hiroyu@jp.fujitsu.com> <20090115111420.8559bdb3.nishimura@mxp.nes.nec.co.jp> <20090115133814.a52460fa.nishimura@mxp.nes.nec.co.jp> <20090115141458.818b4e9a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090115141458.818b4e9a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-15 14:14:58]:

> On Thu, 15 Jan 2009 13:38:14 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Thu, 15 Jan 2009 11:14:20 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > > To handle the problem "parent may be obsolete",
> > > > > > 
> > > > > > call mem_cgroup_get(parent) at create()
> > > > > > call mem_cgroup_put(parent) at freeing memcg.
> > > > > >      (regardless of use_hierarchy.)
> > > > > > 
> > > > > > is clearer way to go, I think.
> > > > > > 
> > > > > > I wonder whether there is  mis-accounting problem or not..
> > > > > > 
> > hmm, after more consideration, although this patch can prevent the BUG,
> > it can leak memsw accounting of parents because memsw of parents, which
> > have been incremented by charge, does not decremented.
> > 
> > I'll try pet/put parent approach..
> > Or any other good ideas ?
> > 
> > 
> I believe get/put at create/destroy is enough now..
> Let's try and see what happens.
>

Other approach could be get_hierarchical/put_hierarchical, but that
can quickly get complex. Let us try and avoid it, unless nothing else
works.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
