Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8E0FD6B01AC
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 21:13:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U1D4lK019293
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 10:13:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5266D45DE6E
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:13:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8381A45DE65
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:13:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CBB2E0800A
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:13:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A16DE1800B
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:13:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [ATTEND][LSF/VM TOPIC] Stale Page Tracking
In-Reply-To: <4C2A9197.5000504@redhat.com>
References: <AANLkTinneFEyqkWVW_Q_paAACco_huGBNtf_5fiYckCv@mail.gmail.com> <4C2A9197.5000504@redhat.com>
Message-Id: <20100630101228.3915.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 30 Jun 2010 10:13:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ying Han <yinghan@google.com>, linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On 06/29/2010 08:25 PM, Ying Han wrote:
> > apologies if you got this email twice, the first emails seems not
> > getting through :(
> >
> > This is the discussion we would like to have on the upcoming Linux VM
> > summit.
> >
> > Problem:
> > Google runs large scale of machines and each machine runs Linux. We try
> > to achieve higher utilization by better bin-packing of jobs on existing
> > systems and for this we depend on having accurate resource usage
> > estimation. Linux VM subsystem is designed in a way that it tries to
> > allocate every single page available by filling up page cache pages.
> > Some of the pages might be touched once and never touched again. Pageout
> > deamon(kswapd) only evicts pages under memory pressure, so pages which
> > are actually stale will end up taking memory space. It would be nice to
> > have a way to measure the portion of working set for each process
> > periodically. A user-land resource management program can trigger
> > reclaim of the stale pages making room for packing more jobs any time.
> 
> Something like this functionality could also be useful for
> virtualization, kicking off garbage collection in JVMs and
> other runtimes, as well as resizing other workloads that
> cache data...
> 
> I would like to discuss this topic so we can figure out
> the kind of functionality needed to achieve what everybody
> wants.

Yup. very interesting.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
