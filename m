Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF1696B2A2E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:07:58 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d22-v6so3198351pfn.3
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:07:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w8-v6sor1286260pgm.32.2018.08.23.06.07.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 06:07:57 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 0/3] trivial code refine for sparsemem
Date: Thu, 23 Aug 2018 21:07:29 +0800
Message-Id: <20180823130732.9489-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com, Wei Yang <richard.weiyang@gmail.com>

Here is three trivial refine patches for sparsemem.

Wei Yang (3):
  mm/sparse: add likely to mem_section[root] check in
    sparse_index_init()
  mm/sparse: expand the CONFIG_SPARSEMEM_EXTREME range in
    __nr_to_section()
  mm/sparse: use __highest_present_section_nr as the boundary for pfn
    check

 include/linux/mmzone.h | 6 +++---
 mm/sparse.c            | 3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

-- 
2.15.1
