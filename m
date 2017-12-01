Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05DC96B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 13:31:24 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z37so7360932qtz.16
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 10:31:24 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j92si5394627qtd.299.2017.12.01.10.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 10:31:22 -0800 (PST)
Date: Fri, 1 Dec 2017 10:30:35 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: stalled MM patches
Message-ID: <20171201183035.GH19394@magnolia>
References: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexandru Moise <00moses.alexander00@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrey Vagin <avagin@openvz.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, "Artem S. Tashkinov" <t.artem@lycos.com>, Balbir Singh <bsingharora@gmail.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Glauber Costa <glommer@openvz.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Ingo Molnar <mingo@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Maxim Patlasov <MPatlasov@parallels.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Punit Agrawal <punit.agrawal@arm.com>, Rik van Riel <riel@redhat.com>, Shiraz Hashim <shashim@codeaurora.org>, Tan Xiaojun <tanxiaojun@huawei.com>, Theodore Ts'o <tytso@mit.edu>, Vinayak Menon <vinmenon@codeaurora.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>, linux-mm@kvack.org

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
> 
> Subject: mm: readahead: increase maximum readahead window
> 
>   Darrick said he was going to do some testing.

FWIW I thought Jan said was going to do some testing on a recent kernel...

Referencing the patch itself: ext3 on 4.4 is a bit old for a 4.16 patch, yes?

--D

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
