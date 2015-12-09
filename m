Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id D62276B0259
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:26:21 -0500 (EST)
Received: by obcse5 with SMTP id se5so39212780obc.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:26:21 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id b188si9086179oih.29.2015.12.09.08.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 08:26:20 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 0/2] Change PAT to support mremap use-cases
Date: Wed,  9 Dec 2015 09:26:06 -0700
Message-Id: <1449678368-31793-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de
Cc: stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch-set fixes issues found in the pfn tracking code of PAT
when mremap() is used on a VM_PFNMAP range.

Patch 1/2 changes untrack_pfn() to handle the case of mremap() with
MREMAP_FIXED, i.e. remapping virtual address on a VM_PFNMAP range.

Patch 2/2 changes the free_memtype() path to handle the case of
mremap() that shrinks the size of a VM_PFNMAP range.

Note, mremap() to expand the size of a VM_PFNMAP range is not a valid
case as VM_DONTEXPAND is set along with VM_PFNMAP.

---
Toshi Kani (2):
 1/2 x86/mm/pat: Change untrack_pfn() to handle unmapped vma
 2/2 x86/mm/pat: Change free_memtype() to free shrinking range

---
 arch/x86/mm/pat.c        | 19 ++++++++++++-------
 arch/x86/mm/pat_rbtree.c | 46 +++++++++++++++++++++++++++++++++++++---------
 2 files changed, 49 insertions(+), 16 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
