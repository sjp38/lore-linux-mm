Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2DC6B0088
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 01:22:49 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7A5Mmfg007456
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 10:52:48 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7A5MkaK475338
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 10:52:48 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7A5Mkkw024475
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:22:46 +1000
Date: Mon, 10 Aug 2009 10:52:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Help Resource Counters Scale Better (v3)
Message-ID: <20090810052243.GB5257@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090807221238.GJ9686@balbir.in.ibm.com> <39eafe409b85053081e9c6826005bb06.squirrel@webmail-b.css.fujitsu.com> <20090808060531.GL9686@balbir.in.ibm.com> <99f2a13990d68c34c76c33581949aefd.squirrel@webmail-b.css.fujitsu.com> <20090809121530.GA5833@balbir.in.ibm.com> <20090810093229.10db7185.kamezawa.hiroyu@jp.fujitsu.com> <20090810094344.77a8ef55.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090810094344.77a8ef55.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, andi.kleen@intel.com, Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-10 09:43:44]:

> On Mon, 10 Aug 2009 09:32:29 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 1. you use res_counter_read_positive() in force_empty. It seems force_empty can
> >    go into infinite loop. plz check. (especially when some pages are freed or swapped-in
> >    in other cpu while force_empry runs.)
> > 
> > 2. In near future, we'll see 256 or 1024 cpus on a system, anyway.
> >    Assume 1024cpu system, 64k*1024=64M is a tolerance.
> >    Can't we calculate max-tolerane as following ?
> >   
> >    tolerance = min(64k * num_online_cpus(), limit_in_bytes/100);
> >    tolerance /= num_online_cpus();
> >    per_cpu_tolerance = min(16k, tolelance);
> > 
> >    I think automatic runtine adjusting of tolerance will be finally necessary,
> >    but above will not be very bad because we can guarantee 1% tolerance.
> > 
> 
> Sorry, one more.
> 
> 3. As I requested when you pushed softlimit changes to mmotom, plz consider
>    to implement a way to check-and-notify gadget to res_counter.
>    See: http://marc.info/?l=linux-mm&m=124753058921677&w=2
>

Yes, I will do that, but only after the scaling, since this is more
important at the moment. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
