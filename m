Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A14198D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:54:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AAEFF3EE0AE
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:54:28 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61DA545DE9A
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:54:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A4DFD45DE95
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:54:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E55AE08003
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:54:26 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 56C60E08001
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:54:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
In-Reply-To: <BANLkTik=brAxLRC4yE71nSpOY4Lah4Bb+g@mail.gmail.com>
References: <20110330101716.E921.A69D9226@jp.fujitsu.com> <BANLkTik=brAxLRC4yE71nSpOY4Lah4Bb+g@mail.gmail.com>
Message-Id: <20110330105455.E92D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Mar 2011 10:54:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

> > Currently, memory cgroup don't restrict number of page fault. And we already have
> > this feature by CONFIG_CGROUP_PERF if my understanding is correct. Why don't you
> > use perf cgroup?
> >
> > In the other words, after your patch, we have four pagefault counter. Do we
> > really need *four*? Can't we consolidate them?
> >
> > 1. tsk->maj_flt
> > 2. perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ)
> > 3. count_vm_event(PGMAJFAULT);
> > 4. mem_cgroup_count_vm_event(PGMAJFAULT);
> 
> The first three are per-process and per-system level counters. What I
> did in this patch is to add per-memcg counters for pgfault and
> pgmajfault. This purpose is not to do any limiting but monitoring. I
> am not sure about the CONFIG_CGROUP_PERF, does it require
> CONFIG_PERF_EVENTS?

Yes, per-process counter can be enhanced per-cgroup counter naturally and easily. 
I guess it's a background idea of that.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
