Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42BC86B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:14:28 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id h12so4548124wre.12
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:14:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 30si4057677wra.131.2017.11.30.14.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:14:27 -0800 (PST)
Date: Thu, 30 Nov 2017 14:14:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: stalled MM patches
Message-Id: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrey Vagin <avagin@openvz.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, "Artem S. Tashkinov" <t.artem@lycos.com>, Balbir Singh <bsingharora@gmail.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Glauber Costa <glommer@openvz.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Ingo Molnar <mingo@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Maxim Patlasov <MPatlasov@parallels.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Punit Agrawal <punit.agrawal@arm.com>, Rik van Riel <riel@redhat.com>, Shiraz Hashim <shashim@codeaurora.org>, Tan Xiaojun <tanxiaojun@huawei.com>, Theodore Ts'o <tytso@mit.edu>, Vinayak Menon <vinmenon@codeaurora.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org


I'm sitting on a bunch of patches of varying ages which are stuck for
various reason.  Can people please take a look some time and assist
with getting them merged, dropped or fixed?

I'll send them all out in a sec.  I have rough notes (which might be
obsolete) and additional details can be found by following the Link: in
the individual patches.

Thanks.

Subject: mm: skip HWPoisoned pages when onlining pages

  mhocko had issues with this one.

Subject: mm/mempolicy: remove redundant check in get_nodes
Subject: mm/mempolicy: fix the check of nodemask from user
Subject: mm/mempolicy: add nodes_empty check in SYSC_migrate_pages

  Three patch series.  Stuck because vbabka wasn't happy with #3.

Subject: mm: memcontrol: eliminate raw access to stat and event counters
Subject: mm: memcontrol: implement lruvec stat functions on top of each other
Subject: mm: memcontrol: fix excessive complexity in memory.stat reporting

  Three patch series.  Stuck because #3 caused fengguang-bot to
  report "BUG: using __this_cpu_xchg() in preemptible"

Subject: mm/madvise: enable soft offline of HugeTLB pages at PUD level

  Hoping for Kirill review.  I wanted additional code comments (I
  think).  mhocko nacked it.

Subject: mm: readahead: increase maximum readahead window

  Darrick said he was going to do some testing.

Subject: fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory

  I had some questions, but they were responded to, whcih made my
  head spin a bit.  I guess I'll push this to Linus but would
  appreciate additional review.

Subject: mm, hugetlb: remove hugepages_treat_as_movable sysctl

  I'm holding this for additional testing.  I guess I'll merge it in
  4.16-rc1.

Subject: mm: vmscan: do not pass reclaimed slab to vmpressure

  mhocko asked for a changelog update

Subject: mm/page_owner: align with pageblock_nr pages

  mhocko sounded confused and I don't think that was resolved?

Subject: mm/vmstat.c: walk the zone in pageblock_nr_pages steps

  Joonsoo asked for a new changelog.  Various other concerns.

Subject: mm: add strictlimit knob

  This is three years old and I don't think we ever saw a convincing
  case for merging it.  Opinions>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
