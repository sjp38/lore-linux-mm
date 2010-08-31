Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 34B4B6B01F0
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 02:33:42 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7V6RLAm022544
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 02:27:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7V6XcdK315114
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 02:33:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7V6XctU020347
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 02:33:38 -0400
Date: Tue, 31 Aug 2010 12:03:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/5] cgroup: do ID allocation under css allocator.
Message-ID: <20100831063334.GM32680@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
 <20100825170640.5f365629.kamezawa.hiroyu@jp.fujitsu.com>
 <20100825141500.GA32680@balbir.in.ibm.com>
 <20100826091346.88eb3ecc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100826091346.88eb3ecc.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-26 09:13:46]:

> On Wed, 25 Aug 2010 19:45:00 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-25 17:06:40]:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > Now, css'id is allocated after ->create() is called. But to make use of ID
> > > in ->create(), it should be available before ->create().
> > > 
> > > In another thinking, considering the ID is tightly coupled with "css",
> > > it should be allocated when "css" is allocated.
> > > This patch moves alloc_css_id() to css allocation routine. Now, only 2 subsys,
> > > memory and blkio are useing ID. (To support complicated hierarchy walk.)
> >                        ^^^^ typo
> > > 
> > > ID will be used in mem cgroup's ->create(), later.
> > > 
> > > Note:
> > > If someone changes rules of css allocation, ID allocation should be moved too.
> > > 
> > 
> > What rules? could you please elaborate?
> > 
> See Paul Menage's mail. He said "allocating css object under kernel/cgroup.c
> will make kernel/cgroup.c cleaner." But it seems too big for my purpose.
> 
> > Seems cleaner, may be we need to update cgroups.txt?
> 
> Hmm. will look into.
>

OK, the patch looks good to me otherwise

 
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
