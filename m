Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6398C6B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 19:55:44 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q3-v6so5106903qki.4
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:55:44 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x45-v6si9153628qtk.32.2018.07.24.16.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 16:55:43 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH 0/3] memmap_init_zone improvements
Date: Tue, 24 Jul 2018 19:55:17 -0400
Message-Id: <20180724235520.10200-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

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
 mm/page_alloc.c                 | 115 +++++++++++++++-----------------
 2 files changed, 55 insertions(+), 61 deletions(-)

-- 
2.18.0
