Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C8E5A6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 07:34:19 -0400 (EDT)
Message-ID: <4BC1B389.20803@redhat.com>
Date: Sun, 11 Apr 2010 14:33:29 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <20100410204756.GR5708@random.random> <4BC0E6ED.7040100@redhat.com> <20100411010540.GW5708@random.random> <20100411112424.GA10952@elte.hu>
In-Reply-To: <20100411112424.GA10952@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 02:24 PM, Ingo Molnar wrote:
> * Andrea Arcangeli<aarcange@redhat.com>  wrote:
>
>    
>> So this takes more than 2 seconds away from 24 seconds reproducibly, and it
>> means gcc now runs 8% faster. [...]
>>      
> That's fantastic if systematic ... i'd give a limb for faster kbuild times in
> the>2% range.
>
> Would be nice to see a precise before/after 'perf stat' comparison:
>
>      perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-load-misses --repeat 3 ...
>
> that way we can see that the instruction count is roughly the same
> before/after, the cycle count goes down and we can also see the reduction in
> dTLB misses (and other advantages, if any).
>
> Plus, here's a hugetlb usability feature request if you dont mind me
> suggesting it.
>
> This current usage (as root):
>
>      echo never>  /sys/kernel/mm/transparent_hugepage/enabled
>
> is fine for testing but it would be also nice to give finegrained per workload
> tunability to such details. It would be _very_ nice to have app-inheritable
> hugetlb attributes plus have a 'hugetlb' tool in tools/hugetlb/, which would
> allow the per workload tuning of hugetlb uses. For example:
>
>      hugetlb ctl --never ./my-workload.sh
>
> would disable hugetlb usage in my-workload.sh (and all sub-processes).
> Running:
>
>      hugetlb ctl --always ./my-workload.sh
>
> would enable it. [or something like that - maybe there are better naming schemes]
>    

I would like to see transparent hugetlb enabled by default for all 
workloads, and good enough so that users don't need to tweak it at all.  
May not happen for the initial merge, but certainly later.


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
