Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 065BA6B00C7
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 04:28:24 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2N9EdQT012424
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 20:14:39 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N9UVVH913514
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 20:30:33 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2N9UDBo031988
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 20:30:13 +1100
Date: Mon, 23 Mar 2009 15:00:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-ID: <20090323093001.GP24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165735.27274.96091.sendpatchset@localhost.localdomain> <20090320124639.83d22726.kamezawa.hiroyu@jp.fujitsu.com> <20090322142105.GA24227@balbir.in.ibm.com> <20090323085314.7cce6c50.kamezawa.hiroyu@jp.fujitsu.com> <20090323033404.GG24227@balbir.in.ibm.com> <20090323123841.caa91874.kamezawa.hiroyu@jp.fujitsu.com> <20090323041559.GI24227@balbir.in.ibm.com> <20090323132308.941b617d.kamezawa.hiroyu@jp.fujitsu.com> <20090323082244.GK24227@balbir.in.ibm.com> <20090323174743.87959966.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323174743.87959966.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 17:47:43]:

> On Mon, 23 Mar 2009 13:52:44 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > I don't see why you are harping about something that you might think
> > is a problem and want to over-optimize even without tests. Fix
> > something when you can see the problem, on my system I don't see it. I
> > am willing to consider alternatives or moving away from the current
> > coding style *iff* it needs to be redone for better performance.
> > 
> 
> It's usually true that "For optimize system, don't do anything unnecessary".
> And the patch increase size of res_counter_charge from 236bytes to 295bytes.
> on my compliler.
>

New features do come with a cost, I expected to add 8 bytes not 59
bytes. Something is wrong, could you help me with offsets and what you
see on your system.
 
> And this is called at every charge if the check is unnecessary.
> (i.e. the _real_ check itself is done once in a HZ/?)
>

So your suggestions is

1. Add a flag to indicate if soft limits are enabled (new atomic field
or field protected by a lock).
2. Every HZ/? walk up the entire tree hold all locks and check if soft
limit is exceeded
3. Or, restrict the child not to have soft limit greater than parent
and break design


 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
