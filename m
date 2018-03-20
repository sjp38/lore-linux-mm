Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99C0D6B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:41 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a22so56659qkc.1
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f52si742292qtc.75.2018.03.19.19.00.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:40 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 00/15] hmm: fixes and documentations v3
Date: Mon, 19 Mar 2018 22:00:22 -0400
Message-Id: <20180320020038.3360-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Added a patch to fix zombie mm_struct (missing call to mmu notifier
unregister) this was lost in translation at some point. Included all
typos and comments received so far (and even more typos fixes). Added
more comments. Updated individual patch version to reflect changes.

Below are previous cover letter (everything in them are still true):

----------------------------------------------------------------------
cover letter for v2:

Removed pointless VM_BUG_ON() cced stable when appropriate and splitted
the last patch into _many_ smaller patches to make it easier to review.
The end result is same modulo comments i received so far and the extra
documentation i added while splitting thing up. Below is previous cover
letter (everything in it is still true):
----------------------------------------------------------------------
cover letter for v1:

All patches only impact HMM user, there is no implication outside HMM.

First patch improve documentation to better reflect what HMM is. Second
patch fix #if/#else placement in hmm.h. The third patch add a call on
mm release which helps device driver who use HMM to clean up early when
a process quit. Finaly last patch modify the CPU snapshot and page fault
helper to simplify device driver. The nouveau patchset i posted last
week already depends on all of those patches.

You can find them in a hmm-for-4.17 branch:

git://people.freedesktop.org/~glisse/linux
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-for-4.17

JA(C)rA'me Glisse (13):
  mm/hmm: fix header file if/else/endif maze v2
  mm/hmm: unregister mmu_notifier when last HMM client quit
  mm/hmm: hmm_pfns_bad() was accessing wrong struct
  mm/hmm: use struct for hmm_vma_fault(), hmm_vma_get_pfns() parameters
    v2
  mm/hmm: remove HMM_PFN_READ flag and ignore peculiar architecture v2
  mm/hmm: use uint64_t for HMM pfn instead of defining hmm_pfn_t to
    ulong v2
  mm/hmm: cleanup special vma handling (VM_SPECIAL)
  mm/hmm: do not differentiate between empty entry or missing directory
    v2
  mm/hmm: rename HMM_PFN_DEVICE_UNADDRESSABLE to HMM_PFN_DEVICE_PRIVATE
  mm/hmm: move hmm_pfns_clear() closer to where it is use
  mm/hmm: factor out pte and pmd handling to simplify hmm_vma_walk_pmd()
  mm/hmm: change hmm_vma_fault() to allow write fault on page basis
  mm/hmm: use device driver encoding for HMM pfn v2

Ralph Campbell (2):
  mm/hmm: documentation editorial update to HMM documentation
  mm/hmm: HMM should have a callback before MM is destroyed v2

 Documentation/vm/hmm.txt | 360 ++++++++++++++++----------------
 MAINTAINERS              |   1 +
 include/linux/hmm.h      | 201 +++++++++++-------
 mm/hmm.c                 | 526 ++++++++++++++++++++++++++++++-----------------
 4 files changed, 648 insertions(+), 440 deletions(-)

-- 
2.14.3
