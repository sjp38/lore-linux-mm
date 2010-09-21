Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B4E146B004A
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 20:57:36 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8L0vYeG003213
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Sep 2010 09:57:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CF53445DE4F
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 09:57:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B1B371EF084
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 09:57:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 617111DB8019
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 09:57:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 809551DB8016
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 09:57:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFCv2][PATCH] add some drop_caches documentation and info messsge
In-Reply-To: <1284738841.25231.4387.camel@nimitz>
References: <20100917092603.3BD5.A69D9226@jp.fujitsu.com> <1284738841.25231.4387.camel@nimitz>
Message-Id: <20100921094658.3BE3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Sep 2010 09:57:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com
List-ID: <linux-mm.kvack.org>

> On Fri, 2010-09-17 at 09:26 +0900, KOSAKI Motohiro wrote:
> > > diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
> > > --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-16 09:43:52.000000000 -0700
> > > +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-16 09:43:52.000000000 -0700
> > > @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
> > >  {
> > >  	proc_dointvec_minmax(table, write, buffer, length, ppos);
> > >  	if (write) {
> > > +		printk(KERN_NOTICE "%s (%d): dropped kernel caches: %d\n",
> > > +			current->comm, task_pid_nr(current), sysctl_drop_caches);
> > >  		if (sysctl_drop_caches & 1)
> > >  			iterate_supers(drop_pagecache_sb, NULL);
> > >  		if (sysctl_drop_caches & 2)
> > 
> > Can't you print it only once?
> 
> Sure.  But, I also figured that somebody calling it every minute is
> going to be much more interesting than something just on startup.
> Should we printk_ratelimit() it, perhaps?

Umm...

every minute drop_caches + printk_ratelimit() mean every drop_caches output
printk(). It seems annoying. I'm worry about that I'll see drop_caches's printk fill
my syslog.

But, It is not strong opinion. Because I don't use every minute drop_caches, then
I have no experience such usecase. It's up to you.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
