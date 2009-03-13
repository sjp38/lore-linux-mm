Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 832D26B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:18:22 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2D7IHW0030976
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:48:17 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D7F4Cv3453042
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:45:04 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2D7IGhD019409
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:18:17 +1100
Date: Fri, 13 Mar 2009 12:48:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v5)
Message-ID: <20090313071812.GL16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain> <7c3bfaf94080838cb7c2f7c54959a9f1.squirrel@webmail-b.css.fujitsu.com> <7e852b228b80d8ba468a49bfb6551b6d.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <7e852b228b80d8ba468a49bfb6551b6d.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-13 16:07:35]:

> KAMEZAWA Hiroyuki ?$B$5$s$O=q$-$^$7$?!'
> > Balbir Singh ?$B$5$s$O=q$-$^$7$?!'
> >>
> >> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> >>
> >> New Feature: Soft limits for memory resource controller.
> >>
> >> Changelog v5...v4
> >> 1. Several changes to the reclaim logic, please see the patch 4 (reclaim
> >> on
> >>    contention). I've experimented with several possibilities for reclaim
> >>    and chose to come back to this due to the excellent behaviour seen
> >> while
> >>    testing the patchset.
> >> 2. Reduced the overhead of soft limits on resource counters very
> >> significantly.
> >>    Reaim benchmark now shows almost no drop in performance.
> >>
> > It seems there are no changes to answer my last comments.
> >
> > Nack again. I'll update my own version again.
> >
> Sigh, this is in -mm ? okay...I'll update onto -mm as much as I can.
> Very heavy work, maybe.

Andrew just dropped it from -mm, so don't rush on updating. I was
about to send fixes to address review comments, but I'll just merge
that in -v6.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
