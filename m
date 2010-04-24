Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA4046B0200
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 00:27:48 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3O4CIGa023313
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 00:12:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3O4RfCI159098
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 00:27:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3O4Re20006896
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 00:27:41 -0400
Date: Fri, 23 Apr 2010 21:27:39 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix v3
Message-ID: <20100424042739.GD2589@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <4BD10D59.9090504@cn.fujitsu.com>
 <20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
 <4BD118E2.7080307@cn.fujitsu.com>
 <4BD11A24.2070500@cn.fujitsu.com>
 <20100423125814.01e95bce.kamezawa.hiroyu@jp.fujitsu.com>
 <20100423130349.f320d0be.kamezawa.hiroyu@jp.fujitsu.com>
 <20100423193406.GD2589@linux.vnet.ibm.com>
 <20100424110805.17c7f86e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100424110805.17c7f86e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 24, 2010 at 11:08:05AM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 23 Apr 2010 12:34:06 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Fri, Apr 23, 2010 at 01:03:49PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Fri, 23 Apr 2010 12:58:14 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Fri, 23 Apr 2010 11:55:16 +0800
> > > > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > > 
> > > > > Li Zefan wrote:
> > > > > > KAMEZAWA Hiroyuki wrote:
> > > > > >> On Fri, 23 Apr 2010 11:00:41 +0800
> > > > > >> Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > > > >>
> > > > > >>> with CONFIG_PROVE_RCU=y, I saw this warning, it's because
> > > > > >>> css_id() is not under rcu_read_lock().
> > > > > >>>
> > > > > >> Ok. Thank you for reporting.
> > > > > >> This is ok ? 
> > > > > > 
> > > > > > Yes, and I did some more simple tests on memcg, no more warning
> > > > > > showed up.
> > > > > > 
> > > > > 
> > > > > oops, after trigging oom, I saw 2 more warnings:
> > > > > 
> > > > 
> > > > Thank you for good testing.
> > > v3 here...sorry too rapid posting...
> > > 
> > > ==
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > I have queued this, thank you all!
> > 
> > However, memcg_oom_wake_function() does not yet exist in the tree
> > I am using, and is_target_pte_for_mc() has changed.  I omitted the
> > hunk for memcg_oom_wake_function() and edited the hunk for
> > is_target_pte_for_mc().
> > 
> Ok, memcg_oom_wake_function is for -mm. I'll prepare another patch for -mm.
> 
> 
> > I have queued this for others' testing, but if you would rather carry
> > this patch up the memcg path, please let me know and I will drop it.
> > 
> I think it's ok to be fixed by your tree. I'll look at memcg later and
> fix remaining things.

Sounds good!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
