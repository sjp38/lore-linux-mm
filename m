Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC566B0055
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 03:42:51 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7A7f8kJ030399
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 17:41:08 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7A7gkk8450980
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 17:42:48 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7A7gjnl021474
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 17:42:46 +1000
Date: Mon, 10 Aug 2009 13:11:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Help Resource Counters Scale Better (v3)
Message-ID: <20090810074134.GA4648@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090807221238.GJ9686@balbir.in.ibm.com> <39eafe409b85053081e9c6826005bb06.squirrel@webmail-b.css.fujitsu.com> <20090808060531.GL9686@balbir.in.ibm.com> <99f2a13990d68c34c76c33581949aefd.squirrel@webmail-b.css.fujitsu.com> <20090809121530.GA5833@balbir.in.ibm.com> <20090810093229.10db7185.kamezawa.hiroyu@jp.fujitsu.com> <20090810053025.GC5257@balbir.in.ibm.com> <20090810144559.ac5a3499.kamezawa.hiroyu@jp.fujitsu.com> <20090810152205.d37d8e2f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090810152205.d37d8e2f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, andi.kleen@intel.com, Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-10 15:22:05]:

> On Mon, 10 Aug 2009 14:45:59 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > Do you agree?
> > 
> > Ok. Config is enough at this stage.
> > 
> > The last advice for merge is, it's better to show the numbers or
> > ask someone who have many cpus to measure benefits. Then, Andrew can
> > know how this is benefical.
> > (My box has 8 cpus. But maybe your IBM collaegue has some bigger one)
> > 
> > In my experience (in my own old trial),
> >  - lock contention itself is low. not high.
> >  - but cacheline-miss, pingpong is very very frequent.
> > 
> > Then, this patch has some benefit logically but, in general,
> > File-I/O, swapin-swapout, page-allocation/initalize etc..dominates
> > the performance of usual apps. You'll have to be careful to select apps
> > to measure the benfits of this patch by application performance.
> > (And this is why I don't feel so much emergency as you do)
> > 
> 
> Why I say "I want to see the numbers" again and again is that
> this is performance improvement with _bad side effect_.
> If this is an emergent trouble, and need fast-track, which requires us
> "fix small problems later", plz say so. 
> 


Yes, this is an emergent trouble, I've gotten reports of the lock
showing up on 16 to 64 ways.

> I have no objection to this approach itself because I can't think of
> something better, now. percpu-counter's error tolerance is a generic
> problem and we'll have to visit this anyway.
>

Yes, my plan is to then later add a strict/no-strict accounting layer
and allow users to choose. Keep root as non-script as we don't
support limit setting on root now. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
