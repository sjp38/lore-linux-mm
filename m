Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 072E66B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 02:20:09 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id e23so10341975oii.9
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 23:20:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g81si266149oic.373.2018.01.31.23.20.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 23:20:06 -0800 (PST)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH 0/2] Optimize the code of mem_map allocation in
Date: Thu,  1 Feb 2018 15:19:54 +0800
Message-Id: <20180201071956.14365-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, douly.fnst@cn.fujitsu.com, Baoquan He <bhe@redhat.com>

In 5-level paging mode, allocating memory with the size of NR_MEM_SECTIONS
is a bad idea. So in this patchset, trying to optimize to save memory.
Othersise kdump kernel can't boot up with normal crashkernel reservation
setting. And for normal kernel, the 512M consumption is not also not
wise, though it's a temporary allocation. 

Baoquan He (2):
  mm/sparsemem: Defer the ms->section_mem_map clearing a little later
  mm/sparse.c: Add nr_present_sections to change the mem_map allocation

 mm/sparse-vmemmap.c |  9 +++++----
 mm/sparse.c         | 54 ++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 42 insertions(+), 21 deletions(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
