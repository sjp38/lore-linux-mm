Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1135B6B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 02:14:14 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8F69LXN027194
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 00:09:21 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8F6EOCS207726
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 00:14:24 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8F6ENU6018174
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 00:14:24 -0600
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100915135016.C9F1.A69D9226@jp.fujitsu.com>
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
	 <20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100915135016.C9F1.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 14 Sep 2010 23:14:22 -0700
Message-ID: <1284531262.27089.15725.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2010-09-15 at 13:53 +0900, KOSAKI Motohiro wrote:
> > >  ==============================================================
> > >  
> > > diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
> > > --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-14 15:44:29.000000000 -0700
> > > +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-14 15:58:31.000000000 -0700
> > > @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
> > >  {
> > >  	proc_dointvec_minmax(table, write, buffer, length, ppos);
> > >  	if (write) {
> > > +		WARN_ONCE(1, "kernel caches forcefully dropped, "
> > > +			     "see Documentation/sysctl/vm.txt\n");
> > 
> > Documentation updeta seems good but showing warning seems to be meddling to me.
> 
> Agreed.
> 
> If the motivation is blog's bogus rumor, this is no effective. I easily
> imazine they will write "Hey, drop_caches may output strange message, 
> but please ignore it!".

Fair enough.  But, is there a point that we _should_ be warning?  If
someone is doing this every minute, or every hour, something is pretty
broken.  Should we at least be doing a WARN_ON() so that the TAINT_WARN
is set?

I'm worried that there are users out there experiencing real problems
that aren't reporting it because "workarounds" like this just paper over
the issue.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
