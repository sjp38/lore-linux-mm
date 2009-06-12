Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D9B8E6B006A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 11:15:02 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id n5CFEOP6028774
	for <linux-mm@kvack.org>; Sat, 13 Jun 2009 01:14:24 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5CFFEBM1028174
	for <linux-mm@kvack.org>; Sat, 13 Jun 2009 01:15:14 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5CFFDBD029956
	for <linux-mm@kvack.org>; Sat, 13 Jun 2009 01:15:14 +1000
Message-ID: <4A3270FE.4090602@linux.vnet.ibm.com>
Date: Fri, 12 Jun 2009 20:45:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] memcg: fix page_cgroup fatal error in FLATMEM
 v2
References: <Pine.LNX.4.64.0906110820170.2258@melkki.cs.Helsinki.FI> <4A31C258.2050404@cn.fujitsu.com> <20090612115501.df12a457.kamezawa.hiroyu@jp.fujitsu.com> <20090612124408.721ba2ae.kamezawa.hiroyu@jp.fujitsu.com> <4A31D326.3030206@cn.fujitsu.com> <20090612143429.76ef2357.kamezawa.hiroyu@jp.fujitsu.com> <84144f020906112321x9912476sb42b5d811741e646@mail.gmail.com> <20090612152922.0e7d1221.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090612152922.0e7d1221.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org, mingo@elte.hu, hannes@cmpxchg.org, torvalds@linux-foundation.org, yinghai@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 12 Jun 2009 09:21:52 +0300
> Pekka Enberg <penberg@cs.helsinki.fi> wrote:
>>> In future,
>>> We stop to support FLATMEM (if no users) or rewrite codes for flatmem
>>> completely. But this will adds more messy codes and (big) overheads.
>>>
>>> Reported-by: Li Zefan <lizf@cn.fujitsu.com>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Looks good to me!
>>
>> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
>>
>> Do you want me to push this to Linus or will you take care of it?
>>
> Could you please push this one ? Typos pointed out by Li Zefan is fixed.
> 
> Thank you all.
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, SLAB is configured in very early stage and it can be used in
> init routine now.
> 
> But replacing alloc_bootmem() in FLAT/DISCONTIGMEM's page_cgroup()
> initialization breaks the allocation, now.
> (Works well in SPARSEMEM case...it supports MEMORY_HOTPLUG and
>  size of page_cgroup is in reasonable size (< 1 << MAX_ORDER.)
> 
> This patch revive FLATMEM+memory cgroup by using alloc_bootmem.
> 
> In future,
> We stop to support FLATMEM (if no users) or rewrite codes for flatmem
> completely.But this will adds more messy codes and overheads.
> 
> Changelog: v1->v2
>  - fixed typos.
> 
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> Tested-by: Li Zefan <lizf@cn.fujitsu.com>
> Reported-by: Li Zefan <lizf@cn.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I see you've responded already, Thanks!

The diff is a bit confusing, was Pekka's patch already integrated, in my version
of mmotm, I don't see the alloc_pages_node() change in my source base.

But overall I agree with the change.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
