Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id BCD3A6B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 07:09:36 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 65so22676620pff.2
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 04:09:36 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id bz9si1691686pab.187.2016.01.21.04.09.35
        for <linux-mm@kvack.org>;
        Thu, 21 Jan 2016 04:09:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/3] Couple of fixes for deferred_split_huge_page()
Date: Thu, 21 Jan 2016 15:09:20 +0300
Message-Id: <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160121012237.GE7119@redhat.com>
References: <20160121012237.GE7119@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrea,

Sorry, I should be noticed and address the issue with scan before...

Patchset below should address your concern.

I've tested it in qemu with fake numa.

Kirill A. Shutemov (3):
  thp: make split_queue per-node
  thp: change deferred_split_count() to return number of THP in queue
  thp: limit number of object to scan on deferred_split_scan()

 include/linux/mmzone.h |  6 +++++
 mm/huge_memory.c       | 64 +++++++++++++++++++++++++-------------------------
 mm/page_alloc.c        |  5 ++++
 3 files changed, 43 insertions(+), 32 deletions(-)

-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
