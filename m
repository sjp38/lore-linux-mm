Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 04C958D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:37:54 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p2U1bp1m028459
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:37:51 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by wpaz13.hot.corp.google.com with ESMTP id p2U1bnqZ032419
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:37:49 -0700
Received: by qyk10 with SMTP id 10so685340qyk.11
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:37:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110330101716.E921.A69D9226@jp.fujitsu.com>
References: <1301419953-2282-1-git-send-email-yinghan@google.com>
	<20110330101716.E921.A69D9226@jp.fujitsu.com>
Date: Tue, 29 Mar 2011 18:37:49 -0700
Message-ID: <BANLkTik=brAxLRC4yE71nSpOY4Lah4Bb+g@mail.gmail.com>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Mar 29, 2011 at 6:16 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
> sorry, I didn't see past discussion of this thread. then, I may be missing
> something.
>
>> Two new stats in per-memcg memory.stat which tracks the number of
>> page faults and number of major page faults.
>>
>> "pgfault"
>> "pgmajfault"
>>
>> They are different from "pgpgin"/"pgpgout" stat which count number of
>> pages charged/discharged to the cgroup and have no meaning of reading/
>> writing page to disk.
>>
>> It is valuable to track the two stats for both measuring application's
>> performance as well as the efficiency of the kernel page reclaim path.
>> Counting pagefaults per process is useful, but we also need the aggregated
>> value since processes are monitored and controlled in cgroup basis in memcg.
>
> Currently, memory cgroup don't restrict number of page fault. And we already have
> this feature by CONFIG_CGROUP_PERF if my understanding is correct. Why don't you
> use perf cgroup?
>
> In the other words, after your patch, we have four pagefault counter. Do we
> really need *four*? Can't we consolidate them?
>
> 1. tsk->maj_flt
> 2. perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ)
> 3. count_vm_event(PGMAJFAULT);
> 4. mem_cgroup_count_vm_event(PGMAJFAULT);

The first three are per-process and per-system level counters. What I
did in this patch is to add per-memcg counters for pgfault and
pgmajfault. This purpose is not to do any limiting but monitoring. I
am not sure about the CONFIG_CGROUP_PERF, does it require
CONFIG_PERF_EVENTS?

Thanks

--Ying
>
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
