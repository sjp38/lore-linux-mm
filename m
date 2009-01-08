Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 17F5E6B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 23:41:17 -0500 (EST)
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id n084dcA2019630
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 15:39:38 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n084f7Oo285286
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 15:41:08 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n084f7H3001938
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 15:41:07 +1100
Date: Thu, 8 Jan 2009 10:11:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 3/4] Memory controller soft limit organize cgroups
Message-ID: <20090108044108.GG7294@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain> <20090107184128.18062.96016.sendpatchset@localhost.localdomain> <20090108101148.96e688f4.kamezawa.hiroyu@jp.fujitsu.com> <20090108042558.GC7294@balbir.in.ibm.com> <20090108132855.77d3d3d4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108132855.77d3d3d4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 13:28:55]:

> On Thu, 8 Jan 2009 09:55:58 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 10:11:48]:
> > > Hmm,  Could you clarify following ?
> > >   
> > >   - Usage of memory at insertsion and usage of memory at reclaim is different.
> > >     So, this *sorted* order by RB-tree isn't the best order in general.
> > 
> > True, but we frequently update the tree at an interval of HZ/4.
> > Updating at every page fault sounded like an overkill and building the
> > entire tree at reclaim is an overkill too.
> > 
> "sort" is not necessary.
> If this feature is implemented as background daemon,
> just select the worst one at each iteration is enough.

OK, definitely an alternative worth considering, but the trade-off is
lazy building (your suggestion), which involves actively seeing the
usage of all cgroups (and if they are large, O(c), c is number of
cgroups can be quite a bit) versus building the tree as and when the
fault occurs and controlled by some interval.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
