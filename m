Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 318F76B01AC
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 20:37:19 -0400 (EDT)
Message-ID: <4C2A9197.5000504@redhat.com>
Date: Tue, 29 Jun 2010 20:36:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [ATTEND][LSF/VM TOPIC] Stale Page Tracking
References: <AANLkTinneFEyqkWVW_Q_paAACco_huGBNtf_5fiYckCv@mail.gmail.com>
In-Reply-To: <AANLkTinneFEyqkWVW_Q_paAACco_huGBNtf_5fiYckCv@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 06/29/2010 08:25 PM, Ying Han wrote:
> apologies if you got this email twice, the first emails seems not
> getting through :(
>
> This is the discussion we would like to have on the upcoming Linux VM
> summit.
>
> Problem:
> Google runs large scale of machines and each machine runs Linux. We try
> to achieve higher utilization by better bin-packing of jobs on existing
> systems and for this we depend on having accurate resource usage
> estimation. Linux VM subsystem is designed in a way that it tries to
> allocate every single page available by filling up page cache pages.
> Some of the pages might be touched once and never touched again. Pageout
> deamon(kswapd) only evicts pages under memory pressure, so pages which
> are actually stale will end up taking memory space. It would be nice to
> have a way to measure the portion of working set for each process
> periodically. A user-land resource management program can trigger
> reclaim of the stale pages making room for packing more jobs any time.

Something like this functionality could also be useful for
virtualization, kicking off garbage collection in JVMs and
other runtimes, as well as resizing other workloads that
cache data...

I would like to discuss this topic so we can figure out
the kind of functionality needed to achieve what everybody
wants.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
