Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6009E6B000D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:35:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12-v6so1190062edi.12
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:35:32 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g2-v6si1434611edc.349.2018.07.26.12.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 12:35:31 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 0/3] memmap_init_zone improvements
Date: Thu, 26 Jul 2018 15:35:06 -0400
Message-Id: <20180726193509.3326-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

Changelog:

v1 - v2
	- Merged with linux-next
	- Removed inline from functions that have static variables.
	- Added a comment to defer_init() that it is called early in
	  boot and therefore no need to protect static.

Three small patches that improve memmap_init_zone() and also fix a small
deferred pages bug.

The improvements include reducing number of ifdefs and making code more
modular.

The bug is the deferred_init_update() should be called after the mirrored
memory skipping is taken into account.

Pavel Tatashin (3):
  mm: make memmap_init a proper function
  mm: calculate deferred pages after skipping mirrored memory
  mm: move mirrored memory specific code outside of memmap_init_zone

 arch/ia64/include/asm/pgtable.h |   1 -
 mm/page_alloc.c                 | 124 ++++++++++++++++----------------
 2 files changed, 62 insertions(+), 63 deletions(-)

-- 
2.18.0
