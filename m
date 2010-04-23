Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA4E06B01E3
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 03:00:19 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp03.au.ibm.com (8.14.3/8.13.1) with ESMTP id o3N6uuau005585
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:56:56 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3N70D9O1630298
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 17:00:13 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3N70DmU017121
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 17:00:13 +1000
Date: Fri, 23 Apr 2010 12:30:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix v3
Message-ID: <20100423070011.GS3994@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <4BD10D59.9090504@cn.fujitsu.com>
 <20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
 <4BD118E2.7080307@cn.fujitsu.com>
 <4BD11A24.2070500@cn.fujitsu.com>
 <20100423125814.01e95bce.kamezawa.hiroyu@jp.fujitsu.com>
 <20100423130349.f320d0be.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100423130349.f320d0be.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-04-23 13:03:49]:

> On Fri, 23 Apr 2010 12:58:14 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Fri, 23 Apr 2010 11:55:16 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> > > Li Zefan wrote:
> > > > KAMEZAWA Hiroyuki wrote:
> > > >> On Fri, 23 Apr 2010 11:00:41 +0800
> > > >> Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > >>
> > > >>> with CONFIG_PROVE_RCU=y, I saw this warning, it's because
> > > >>> css_id() is not under rcu_read_lock().
> > > >>>
> > > >> Ok. Thank you for reporting.
> > > >> This is ok ? 
> > > > 
> > > > Yes, and I did some more simple tests on memcg, no more warning
> > > > showed up.
> > > > 
> > > 
> > > oops, after trigging oom, I saw 2 more warnings:
> > > 
> > 
> > Thank you for good testing.
> v3 here...sorry too rapid posting...
> 

Looking at the patch we seem to be protecting the use of only css_*().
I wonder if we should push down the rcu_read_*lock() semnatics to the
css routines or is it just too instrusive to do it that way?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
