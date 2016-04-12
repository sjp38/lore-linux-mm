Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1986B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 15:55:10 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id f52so25556870qga.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 12:55:10 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [23.79.238.175])
        by mx.google.com with ESMTP id g93si25699873qgf.80.2016.04.12.12.55.09
        for <linux-mm@kvack.org>;
        Tue, 12 Apr 2016 12:55:09 -0700 (PDT)
From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH 0/1] mm: setting of min_free_kbytes
Date: Tue, 12 Apr 2016 15:54:36 -0400
Message-Id: <cover.1460488349.git.jbaron@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com
Cc: rientjes@google.com, aarcange@redhat.com, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

While updating a workload to a 4.1 kernel (from 3.14), I found that
min_free_kbytes was automatically set to 11365, whereas on 3.14 it was
67584. This is caused by a change to how min_free_kbytes is set when
CONFIG_TRANSPARENT_HUGEPAGE=y, which is detailed in the patch that
follows.

I was wondering as well if the setting of min_free_kbytes could be
improved in the following cases while looking at this code:

1) memory hotplug

we call init_per_zone_wmark_min() but not
set_recommended_min_free_kbytes() (for hugepages)

2) when khugepaged is stopped

Do we want to undo any settings thath khugepaged has done in that
case to restore the default settings

Thanks,

-Jason

Jason Baron (1):
  mm: update min_free_kbytes from khugepaged after core initialization

 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
