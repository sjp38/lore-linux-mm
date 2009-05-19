Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E4EFD6B0055
	for <linux-mm@kvack.org>; Tue, 19 May 2009 03:09:53 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J7A0gG000534
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 May 2009 16:10:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 54E3F45DE53
	for <linux-mm@kvack.org>; Tue, 19 May 2009 16:10:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2960E45DE5B
	for <linux-mm@kvack.org>; Tue, 19 May 2009 16:10:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4FAD1DB803A
	for <linux-mm@kvack.org>; Tue, 19 May 2009 16:09:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FB5DE38001
	for <linux-mm@kvack.org>; Tue, 19 May 2009 16:09:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <4D05DB80B95B23498C72C700BD6C2E0B2EF6E313@pdsmsx502.ccr.corp.intel.com>
References: <20090519125744.4EC3.A69D9226@jp.fujitsu.com> <4D05DB80B95B23498C72C700BD6C2E0B2EF6E313@pdsmsx502.ccr.corp.intel.com>
Message-Id: <20090519141050.4ED5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 May 2009 16:09:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Wu, Fengguang" <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> >>> >>Now, it was breaked. What should we do?
> >>> >>Yanmin, We know 99% linux people use intel cpu and you are one of
> >>> >>most hard repeated testing
> >>> [YM] It's very easy to reproduce them on my machines. :) Sometimes, because
> >>the
> >>> issues only exist on machines with lots of cpu while other community
> >>developers
> >>> have no such environments.
> >>>
> >>>
> >>>  guy in lkml and you have much test.
> >>> >>May I ask your tested machine and benchmark?
> >>> [YM] Usually I started lots of benchmark testing against the latest kernel,
> >>but
> >>> as for this issue, it's reported by a customer firstly. The customer runs
> >>apache
> >>> on Nehalem machines to access lots of files. So the issue is an example of
> >>file
> >>> server.
> >>
> >>hmmm.
> >>I'm surprised this report. I didn't know this problem. oh..
> [YM] Did you run file server workload on such NUMA machine with
>  zone_reclaim_mode=1? If all nodes have the same memory, the behavior is
> obvious.

I missed your point. I agree file server case is obvious. but I don't
think anybody oppose this.



> >>Actually, I don't think apache is only file server.
> >>apache is one of killer application in linux. it run on very widely
> >>organization.
> [YM] I know that. Apache could support document, ecommerce, and lots of other
> usage models. What I mean is one of customers hit it with their
> workload.

hmhm, ok.


> >>you think large machine don't run apache? I don't think so.
> >>
> >>
> >>
> >>> BTW, I found many test cases of fio have big drop after I upgraded BIOS of
> >>one
> >>> Nehalem machine. By checking vmstat data, I found almost a half memory is
> >>always free. It's also related to zone_reclaim_mode because new BIOS changes
> >>the node
> >>> distance to a large value. I use numactl --interleave=all to walkaround the
> >>problem temporarily.
> >>>
> >>> I have no HPC environment.
> >>
> >>Yeah, that's ok. I and cristoph have. My worries is my unknown workload become
> >>regression.
> >>so, May I assume you run your benchmark both zonre reclaim 0 and 1 and you
> >>haven't seen regression by non-zone reclaim mode?
> [YM] what is non-zone reclaim mode? When zone_reclaim_mode=0?
> I didn't do that intentionally. Currently I just make sure FIO has a big drop
>  when zone_reclaim_mode=1. I might test it with other benchmarks on 2 Nehalem machines.

May I ask what is FIO?
File IO?


> >>if so, it encourage very much to me.
> >>
> >>if zone reclaim mode disabling don't have regression, I'll pushing to
> >>remove default zone reclaim mode completely again.
> [YM] I run lots of benchmarks, but it doesn't mean I run all benchmarks, especially
> no HPC. 

Of cource. nobody can run all benchmark in the world :)



> >>> >>if zone_reclaim=0 tendency workload is much than zone_reclaim=1 tendency
> >>> >>workload,
> >>> >> we can drop our afraid and we would prioritize your opinion, of cource.
> >>> So it seems only file servers have the issue currently.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
