Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9616B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 13:05:19 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id n8TH6oag000896
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 22:36:50 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8TH6neb2863254
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 22:36:49 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8TH6nc4015361
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 03:06:49 +1000
Date: Tue, 29 Sep 2009 22:36:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] memcg: some modification to softlimit under
 hierarchical memory reclaim.
Message-ID: <20090929170632.GA3071@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090929150141.0e672290.kamezawa.hiroyu@jp.fujitsu.com>
 <20090929061132.GA498@balbir.in.ibm.com>
 <20090929183321.3d4fbc1d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090929183321.3d4fbc1d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-29 18:33:21]:

> On Tue, 29 Sep 2009 11:41:32 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-29 15:01:41]:
> > 
> > > No major changes in this patch for 3 weeks.
> > > While testing, I found a few css->refcnt bug in softlimit.(and posted patches)
> > > But it seems no more (easy) ones.
> > >
> > 
> > Kamezawa-San, this worries me, could you please confirm if you are
> > able to see this behaviour without your patches applied as well? I am
> > doing some more stress tests on my side.
> >  
> I found an easy way to reprocue. And yes, it can happen without this series.
>

Kamezawa-San,

Yes, your fix does work and the machine no longer gives a
BUG_ON()/WARN_ON(). Thanks for the analysis and fix.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
