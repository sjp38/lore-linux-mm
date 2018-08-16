Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D000A6B0007
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 06:06:37 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id b7-v6so3308650qtp.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:06:37 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l44-v6si12511131qtl.165.2018.08.16.03.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 03:06:37 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 0/5] mm/memory_hotplug: online/offline_pages refactorings
Date: Thu, 16 Aug 2018 12:06:23 +0200
Message-Id: <20180816100628.26428-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, David Hildenbrand <david@redhat.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

While looking into onlining/offlining of subsections, I noticed that
online/offlining code can in its current form only deal with whole sections
and that onlining/offlining of sections that are already online/offline is
problematic. So let's add some additional checks (that also serve as
implicit documentation) and do some cleanups.

David Hildenbrand (5):
  mm/memory_hotplug: drop intermediate __offline_pages
  mm/memory_hotplug: enforce section alignment when onlining/offlining
  mm/memory_hotplug: check if sections are already online/offline
  mm/memory_hotplug: onlining pages can only fail due to notifiers
  mm/memory_hotplug: print only with DEBUG_VM in online/offline_pages()

 include/linux/mmzone.h |  2 ++
 mm/memory_hotplug.c    | 43 ++++++++++++++++++++++--------------------
 mm/sparse.c            | 28 +++++++++++++++++++++++++++
 3 files changed, 53 insertions(+), 20 deletions(-)

-- 
2.17.1
