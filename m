Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B327B6B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 11:54:05 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8HFkQBn018251
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:46:26 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o8HFs4a0239658
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:54:04 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8HFs3sA006129
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 09:54:04 -0600
Subject: Re: [RFCv2][PATCH] add some drop_caches documentation and info
 messsge
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100917092603.3BD5.A69D9226@jp.fujitsu.com>
References: <20100916165047.DAD42998@kernel.beaverton.ibm.com>
	 <20100917092603.3BD5.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 17 Sep 2010 08:54:01 -0700
Message-ID: <1284738841.25231.4387.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-09-17 at 09:26 +0900, KOSAKI Motohiro wrote:
> > diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
> > --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-16 09:43:52.000000000 -0700
> > +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-16 09:43:52.000000000 -0700
> > @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
> >  {
> >  	proc_dointvec_minmax(table, write, buffer, length, ppos);
> >  	if (write) {
> > +		printk(KERN_NOTICE "%s (%d): dropped kernel caches: %d\n",
> > +			current->comm, task_pid_nr(current), sysctl_drop_caches);
> >  		if (sysctl_drop_caches & 1)
> >  			iterate_supers(drop_pagecache_sb, NULL);
> >  		if (sysctl_drop_caches & 2)
> 
> Can't you print it only once?

Sure.  But, I also figured that somebody calling it every minute is
going to be much more interesting than something just on startup.
Should we printk_ratelimit() it, perhaps?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
