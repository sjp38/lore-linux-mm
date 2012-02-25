Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 0E51E6B004D
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 00:34:09 -0500 (EST)
Received: by bkty12 with SMTP id y12so3463363bkt.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 21:34:07 -0800 (PST)
Message-ID: <4F4872CC.1000702@openvz.org>
Date: Sat, 25 Feb 2012 09:34:04 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/21] mm: lru_lock splitting
References: <20120223133728.12988.5432.stgit@zurg> <1330128354.13358.43.camel@schen9-DESK>
In-Reply-To: <1330128354.13358.43.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>

Tim Chen wrote:
> On Thu, 2012-02-23 at 17:51 +0400, Konstantin Khlebnikov wrote:
>> v3 changes:
>> * inactive-ratio reworked again, now it always calculated from from scratch
>> * hierarchical pte reference bits filter in memory-cgroup reclaimer
>> * fixed two bugs in locking, found by Hugh Dickins
>> * locking functions slightly simplified
>> * new patch for isolated pages accounting
>> * new patch with lru interleaving
>>
>> This patchset is based on next-20120210
>>
>> git: https://github.com/koct9i/linux/commits/lruvec-v3
>>
>> ---
>
> I am seeing an improvement of about 7% in throughput in a workload where
> I am doing parallel reading of files that are mmaped. The contention on
> lru_lock used to be 13% in the cpu profile on the __pagevec_lru_add code
> path. Now lock contention on this path drops to about 0.6%.  I have 40
> hyper-threaded enabled cpu cores running 80 mmaped file reading
> processes.
>
> So initial testing of this patch set looks encouraging.

That's great!

>
> Tim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
