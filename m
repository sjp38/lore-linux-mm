Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0846B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 13:19:45 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7CHJj8I008186
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 22:49:45 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7CHJg6d1380550
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 22:49:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7CHJguT010295
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 03:19:42 +1000
Date: Wed, 12 Aug 2009 22:49:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Help Resource Counters Scale better (v4.1)
Message-ID: <20090812171940.GD5087@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090811144405.GW7176@balbir.in.ibm.com> <20090811163159.ddc5f5fd.akpm@linux-foundation.org> <20090812045716.GH7176@balbir.in.ibm.com> <49a88ef4a1ba9ec9426febe9e3633b89.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <49a88ef4a1ba9ec9426febe9e3633b89.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp, kosaki.motohiro@jp.fujitsu.com, menage@google.com, prarit@redhat.com, andi.kleen@intel.com, xemul@openvz.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-13 01:28:57]:

> Balbir Singh wrote:
> > Hi, Andrew,
> >
> > Does this look better, could you please replace the older patch with
> > this one.
> >
> > 1. I did a quick compile test
> > 2. Ran scripts/checkpatch.pl
> >
> 
> In general, seems reasonable to me as quick hack for root cgroup.
> thank you.
> 
> Reviewed-by: KAMEAZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>

Thanks, yes, we still need to do the percpu counter work, but this
will give us breathing space to do it correctly and define strict and
non-strict accounting.
 
> Finally, we'll have to do some rework for light-weight res_counter.
> But yes, it will take some amount of time.
> My only concern is account leak, but, if some leak, it's current code's
> bug, not this patch.
> 

Yeah.. we'll need to check for that.

> And..hmm...I like following style other than open-coded.
> ==
> int mem_coutner_charge(struct mem_cgroup *mem)
> {
>       if (mem_cgroup_is_root(mem))
>                return 0; // always success
>       return res_counter_charge(....)
> }
> ==
> But maybe nitpick.
> 

Yes, we can refactor for simplication, but we'll need some exceptions.
I'll do that as an add-on patch.



-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
