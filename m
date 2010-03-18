Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9B26B013E
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 00:20:02 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp07.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2I4JrS0031003
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 15:19:53 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2I4Jrnd1585276
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 15:19:53 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2I4JqZg022825
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 15:19:53 +1100
Date: Thu, 18 Mar 2010 09:49:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-ID: <20100318041944.GA18054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <1268609202-15581-2-git-send-email-arighi@develer.com>
 <20100317115855.GS18054@balbir.in.ibm.com>
 <20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 08:54:11]:

> On Wed, 17 Mar 2010 17:28:55 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Andrea Righi <arighi@develer.com> [2010-03-15 00:26:38]:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > Now, file-mapped is maintaiend. But more generic update function
> > > will be needed for dirty page accounting.
> > > 
> > > For accountig page status, we have to guarantee lock_page_cgroup()
> > > will be never called under tree_lock held.
> > > To guarantee that, we use trylock at updating status.
> > > By this, we do fuzzy accounting, but in almost all case, it's correct.
> > >
> > 
> > I don't like this at all, but in almost all cases is not acceptable
> > for statistics, since decisions will be made on them and having them
> > incorrect is really bad. Could we do a form of deferred statistics and
> > fix this.
> > 
> 
> plz show your implementation which has no performance regresssion.
> For me, I don't neee file_mapped accounting, at all. If we can remove that,
> we can add simple migration lock.

That doesn't matter, if you need it, I think the larger user base
matters. Unmapped and mapped page cache is critical and I use it
almost daily.

> file_mapped is a feattue you added. please improve it.
>

I will, but please don't break it silently

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
