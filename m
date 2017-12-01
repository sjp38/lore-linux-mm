Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36A126B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 03:32:06 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e128so635372wmg.1
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 00:32:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d17sor2802354wra.10.2017.12.01.00.32.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Dec 2017 00:32:04 -0800 (PST)
Date: Fri, 1 Dec 2017 09:31:55 +0100
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: stalled MM patches
Message-ID: <20171201083154.GA7108@gmail.com>
References: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Andrey Vagin <avagin@openvz.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, "Artem S. Tashkinov" <t.artem@lycos.com>, Balbir Singh <bsingharora@gmail.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Glauber Costa <glommer@openvz.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Ingo Molnar <mingo@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Maxim Patlasov <MPatlasov@parallels.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Punit Agrawal <punit.agrawal@arm.com>, Rik van Riel <riel@redhat.com>, Shiraz Hashim <shashim@codeaurora.org>, Tan Xiaojun <tanxiaojun@huawei.com>, Theodore Ts'o <tytso@mit.edu>, Vinayak Menon <vinmenon@codeaurora.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>, linux-mm@kvack.org

On Thu, Nov 30, 2017 at 02:14:23PM -0800, Andrew Morton wrote:
> 
> I'm sitting on a bunch of patches of varying ages which are stuck for
> various reason.  Can people please take a look some time and assist
> with getting them merged, dropped or fixed?
> 
> I'll send them all out in a sec.  I have rough notes (which might be
> obsolete) and additional details can be found by following the Link: in
> the individual patches.
> 
> Thanks.
> 
> Subject: mm: skip HWPoisoned pages when onlining pages
> 
>   mhocko had issues with this one.
> 
> Subject: mm/mempolicy: remove redundant check in get_nodes
> Subject: mm/mempolicy: fix the check of nodemask from user
> Subject: mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
> 
>   Three patch series.  Stuck because vbabka wasn't happy with #3.
> 
> Subject: mm: memcontrol: eliminate raw access to stat and event counters
> Subject: mm: memcontrol: implement lruvec stat functions on top of each other
> Subject: mm: memcontrol: fix excessive complexity in memory.stat reporting
> 
>   Three patch series.  Stuck because #3 caused fengguang-bot to
>   report "BUG: using __this_cpu_xchg() in preemptible"
> 
> Subject: mm/madvise: enable soft offline of HugeTLB pages at PUD level
> 
>   Hoping for Kirill review.  I wanted additional code comments (I
>   think).  mhocko nacked it.

TBH I'd rather give up this one if mhocko feels that there's no point to it.
Rather drop it than risk adding crap in the kernel :).

It is a bit weird though that currently we have the behavior that on some PPC platforms
you can migrate 1G hugepages but on x86_64 you cannot.

../Alex

> 
> Subject: mm: readahead: increase maximum readahead window
> 
>   Darrick said he was going to do some testing.
> 
> Subject: fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory
> 
>   I had some questions, but they were responded to, whcih made my
>   head spin a bit.  I guess I'll push this to Linus but would
>   appreciate additional review.
> 
> Subject: mm, hugetlb: remove hugepages_treat_as_movable sysctl
> 
>   I'm holding this for additional testing.  I guess I'll merge it in
>   4.16-rc1.
> 
> Subject: mm: vmscan: do not pass reclaimed slab to vmpressure
> 
>   mhocko asked for a changelog update
> 
> Subject: mm/page_owner: align with pageblock_nr pages
> 
>   mhocko sounded confused and I don't think that was resolved?
> 
> Subject: mm/vmstat.c: walk the zone in pageblock_nr_pages steps
> 
>   Joonsoo asked for a new changelog.  Various other concerns.
> 
> Subject: mm: add strictlimit knob
> 
>   This is three years old and I don't think we ever saw a convincing
>   case for merging it.  Opinions>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
